# Be the Hook server
# In order for this to work, an OAuth application must be registered with
# GitHub on any GitHub account, and the Authorization callback url must be
# set to the deployed location of the hook ui and path to the authorize route.
# The Client ID, Client Secret should be copied from the GitHub OAuth application
# configuration to the heira settings for hook::client_id and hook::client_secret.
# And you need a private access token that issued from any user account. The identity
# of this user is used for commenting.  This is currently 'hooktest'. This token
# should be copied to the hiera setting for hook::gh_token.
class site::profiles::hook {
  include site::profiles::postgres
  include site::profiles::python35
  include site::profiles::hook::backup

  firewall { '100 Allow web traffic for Hook':
    proto  => 'tcp',
    dport  => '80',
    action => 'accept',
  }

  $app_root = hiera('hook::app_root')
  $app_path = hiera('hook::app_path')
  $db_name = hiera('hook::db_name')
  $db_user = hiera('hook::db_user')
  $db_pass = hiera('hook::db_pass')
  $db_uri = "postgresql://${db_user}:${db_pass}@localhost:5432/${db_name}"
  $secret_key = hiera('hook::secret_key')
  $client_id = hiera('hook::client_id')
  $client_secret = hiera('hook::client_secret')

  postgresql::server::db { $db_name:
      user     => $db_user,
      password => postgresql_password($db_user, $db_pass),
  }

  vcsrepo { $app_root:
    ensure   => latest,
    revision => hiera('hook::app_version'),
    provider => git,
    source   => hiera('hook::app_repo'),
    notify   => Python::Virtualenv[$app_root],
  }

  file {"${app_root}/requirements-local.txt":
    source => 'puppet:///modules/site/profiles/hook/requirements.txt',
    mode   => '0775',
  }

  file { "${app_root}/createdb.py":
    content => epp('site/profiles/hook/createdb.py.epp',
      {
        'app_root'      => $app_root,
        'db_uri'        => $db_uri,
        'secret_key'    => $secret_key,
        'client_id'     => $client_id,
        'client_secret' => $client_secret,
      }
    ),
    notify  => Exec['create-hook-db'],
  }

  file { "${app_root}/app.wsgi":
    content => epp('site/profiles/hook/app.wsgi.epp',
      {
        'app_root'      => $app_root,
        'db_uri'        => $db_uri,
        'secret_key'    => $secret_key,
        'client_id'     => $client_id,
        'client_secret' => $client_secret,
        'gh_token'      => hiera('hook::gh_token'),
      }
    ),
    require => Vcsrepo[$app_root],
    notify  => Python::Virtualenv[$app_root],
  }

  python::virtualenv { $app_root:
    ensure       => present,
    version      => '3',
    requirements => "${app_root}/requirements-local.txt",
    venv_dir     => "${app_root}/venv",
    cwd          => $app_root,
    notify       => Service[hiera('apache_service')],
  }

  exec { 'create-hook-db':
    cwd         => $app_root,
    require     =>
      [
        File["${app_root}/createdb.py"],
        Python::Virtualenv[$app_root],
      ],
    command     => "${app_root}/venv/bin/python3 createdb.py",
    refreshonly => true,
  }

  apache::vhost { 'hook':
    servername                  => hiera('hook::vhost'),
    port                        => '80',
    docroot                     => $app_root,
    wsgi_daemon_process         => 'hook',
    wsgi_daemon_process_options => {
      'python-path' => "${app_root}/venv/lib/python3.5/site-packages"
    },
    wsgi_process_group          => 'hook',
    wsgi_script_aliases         => { $app_path => "${app_root}/app.wsgi" },
  }
}
