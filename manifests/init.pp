# Class: springboot
#
# This module manages springboot
#
# Parameters: none
#
# Actions:
#
# Requires: see Modulefile
#
# Sample Usage:
#
class springboot (
  $group,
  $artifact,
  $ssl_chain,
  $ssl_root = undef,
  $ssl_key,
  $ssl_cert,
  $context_path = '/',
  $ajp_port = 8073,
  $env = undef
) {
  include ::nexus
  include ::apache
  include apache::mod::proxy_ajp
  include apache::mod::ssl
  
  realize(User[spring], Group[spring])
  
  nexus::artifact { 'application' :
    group => $group,
    artifact => $artifact,
    extension => 'jar',
    location => "/opt/${artifact}.jar"  
  }
  
  
  file { "/etc/init/${artifact}.conf" :
    ensure  => file,
    content => template("springboot/upstart.conf.erb"),
  }

  service { $artifact :
    ensure  => running,
    require => File["/etc/init/${artifact}.conf"],
  }

  apache::vhost { 'https' :
    servername => $fqdn,
    port       => '443',
    ssl        => true,
#    ssl_cert   => "/etc/ssl/${artifact}.crt",
#    ssl_key    => "/etc/ssl/private/${artifact}.key",
#    ssl_chain  => $ssl_chain,
#    ssl_ca     => $ssl_root,
    docroot    => '/var/www/html',
    proxy_pass => [
      {path => "${context_path}", url => "ajp://localhost:${ajp_port}${context_path}"}
    ]
  }

  ### Copy the SSL certificates into place ###
  file { "/etc/ssl/private/${artifact}.key" :
    source => $ssl_key,
    notify => Service['apache2'],
  }

  file { "/etc/ssl/${artifact}.crt" :
    source => $ssl_cert,
    notify => Service['apache2'],
  }

  # Notify the apache service if any of the certs have changed
  File <| path == $ssl_chain |>  ~> Service['apache2']
  File <| path == $ssl_root |>     ~> Service['apache2']
}
