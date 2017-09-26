# Webserver setup for Capitains
class capitains::web {
  $proxy_pass = {
    'path'    => '/',
    'url'     => 'http://localhost:5000/',
  }

  $headers = [
      "set Access-Control-Allow-Origin '*'",
      "set Access-Control-Allow-Methods 'GET, POST, OPTIONS'"
  ]

  apache::vhost { 'capitains':
    servername => hiera('capitains::domain'),
    port       => '80',
    docroot    => $capitains::www_root,
    proxy_pass => [$proxy_pass],
    headers    => $headers,
  }

  apache::vhost { 'capitains-ssl':
    servername => hiera('capitains::domain'),
    port       => '443',
    docroot    => $capitains::www_root,
    ssl        => true,
    ssl_cert   => '/etc/ssl/certs/__perseids_org_cert.pem',
    ssl_key    => '/etc/ssl/private/__perseids_org.key',
    ssl_chain  => '/etc/ssl/certs/__perseids_org_interm.cer',
    proxy_pass => [$proxy_pass],
    headers    => $headers,
  }

  firewall { '100 Allow web traffic for Capitains':
    proto  => 'tcp',
    dport  => '80',
    action => 'accept',
  }

  firewall { '100 Allow https traffic for Capitains':
    proto  => 'tcp',
    dport  => '443',
    action => 'accept',
  }
}
