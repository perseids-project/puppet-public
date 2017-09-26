# Run the Digmill app
class site::profiles::digmill {
  require site::profiles::deployer
  include apache
  include site::profiles::python3
  include site::profiles::node::ten

  $app_root = hiera('digmill::app_root')
  $app_path = hiera('digmill::app_path')
  $vhost = hiera('digmill::vhost')

  ensure_packages(['mongodb'])

  file { '/etc/ssl/certs/__perseids_org_cert.pem':
    content => lookup('site::ssl::cert_pem'),
  }

  file { '/etc/ssl/certs/__perseids_org_interm.cer':
    content => lookup('site::ssl::interm_cer'),
  }

  file { '/etc/ssl/private/__perseids_org.key':
    content => lookup('site::ssl::key'),
    mode   => '0640',
  }

  file { $app_root:
    ensure  => directory,
    owner   => 'deployer',
    require => User['deployer'],
  }

  vcsrepo { $app_root:
    ensure   => latest,
    revision => hiera('digmill::app_version'),
    provider => git,
    source   => hiera('digmill::repo_url'),
    user     => 'deployer',
    require  => File[$app_root],
  }

  file { "${app_root}/app.wsgi":
    content => epp('site/profiles/digmill/app.wsgi.epp',
      {
        'app_root' => $app_root,
      }
    ),
    require => Vcsrepo[$app_root],
    notify  => Python::Virtualenv[$app_root],
  }

  file { "${app_root}/digital_milliet/config.cfg":
    owner   => 'deployer',
    source  => 'puppet:///modules/site/profiles/digmill/config.cfg',
    mode    => '0644',
    require => Vcsrepo[$app_root],
  }

  file { '/usr/local/bin/build-dm-js':
    content => epp('site/profiles/digmill/build-dm-js.sh.epp',
      {
        'node_version' => hiera('digmill::node_version'),
      }
    ),
    mode    => '0775',
  }

  exec { 'dm-bower':
    user    => 'deployer',
    cwd     => "${app_root}/digital_milliet",
    command => 'bash --login "/usr/local/bin/build-dm-js"',
    require =>
      [
        File['/usr/local/bin/build-dm-js'],
        Vcsrepo[$app_root]
      ],
    creates => "${app_root}/digital_milliet/bower_components",
  }

  python::virtualenv { $app_root:
    ensure       => present,
    version      => '3',
    requirements => "${app_root}/requirements.txt",
    venv_dir     => "${app_root}/venv",
    cwd          => $app_root,
  }

  # This is to redirect the legacy perseus.org domain to perseids.org.
  # Without SSL, perseus.org cannot support authentication so we will 
  # just redirect everyone to Perseids.
  apache::vhost { 'digmill.perseus':
    servername => 'digmill.perseus.org',
    port       => '80',
    docroot    => '/var/www/digmill_perseus',
    rewrites   =>
      [
        {
          'rewrite_rule' => "^$ https://${vhost} [R,L]",
        },
        {
          'rewrite_rule' => "^/(.*)$ https://${vhost}/\$1 [R,L]",
        },
      ],
  }

  apache::vhost { 'digmill':
    servername                  => $vhost,
    port                        => '80',
    docroot                     => $app_root,
    rewrites                    => hiera('digmill::rewrites'),
    wsgi_daemon_process         => 'dm',
    wsgi_daemon_process_options =>
      {
        'python-path' => "${app_root}/venv/lib/python3.4/site-packages",
      },
    wsgi_process_group          => 'dm',
    wsgi_script_aliases         =>
      {
        $app_path => "${app_root}/app.wsgi",
      },
    directories                 =>
      [
        { 'path'    => $app_root,
          'require' => 'all granted',
        }
      ],
    headers                     =>
      [
        "set Access-Control-Allow-Origin '*'",
        "set Access-Control-Allow-Headers 'Origin, X-Requested-With, Content-Type, Accept'",
      ],
  }

  apache::vhost { 'digmill-ssl':
    servername                  => hiera('digmill::vhost'),
    port                        => '443',
    docroot                     => $app_root,
    rewrites                    => hiera('digmill::rewrites'),
    ssl                         => true,
    ssl_cert                    => '/etc/ssl/certs/__perseids_org_cert.pem',
    ssl_key                     => '/etc/ssl/private/__perseids_org.key',
    ssl_chain                   => '/etc/ssl/certs/__perseids_org_interm.cer',
    wsgi_daemon_process         => 'dm-ssl',
    wsgi_daemon_process_options =>
      {
        'python-path' => "${app_root}/venv/lib/python3.4/site-packages",
      },
    wsgi_process_group          => 'dm-ssl',
    wsgi_script_aliases         =>
      {
        $app_path => "${app_root}/app.wsgi",
      },
    directories                 =>
      [
        {
          'path'    => $app_root,
          'require' => 'all granted',
        },
      ],
    headers                     =>
      [
        "set Access-Control-Allow-Origin '*'",
        "set Access-Control-Allow-Headers 'Origin, X-Requested-With, Content-Type, Accept'",
      ],
  }

  firewall { '100 Allow web traffic for digmill':
    proto  => 'tcp',
    dport  => '80',
    action => 'accept',
  }

  firewall { '100 Allow ssltraffic for digmill':
    proto  => 'tcp',
    dport  => '443',
    action => 'accept',
  }

  firewall { '100 Allow py for digmill':
    proto  => 'tcp',
    dport  => '5000',
    action => 'accept',
  }

  cron { 'dump-mongo':
    command => '/usr/bin/mongodump -o /usr/local/mongo_backup >/var/log/mongodump.log 2>&1',
    minute  => '45',
    hour    => '*/6',
  }

  common::duplicity_job { 'digmil_data':
    path => '/usr/local/mongo_backup',
  }
}
