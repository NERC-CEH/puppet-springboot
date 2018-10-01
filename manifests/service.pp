# class to setup service
class springboot::service (
  $artifact,
  $env,
) {

  if $::operatingsystem != 'Ubuntu' {
    fail("${::operatingsystem} not supported")
  }

  # Will assume 14.04 -> upstart, 15+ -> systemd
  $init_type = $::operatingsystemmajrelease ? {
    /1[2-4].*/ => 'upstart',
    default    => 'systemd',
  }

  if $init_type == 'upstart' {
    file { "/etc/init/${artifact}.conf" :
      ensure  => file,
      content => template('springboot/upstart.conf.erb'),
    }
    service { $artifact :
      ensure  => running,
      require => File["/etc/init/${artifact}.conf"],
    }
  } elsif $init_type == 'systemd' { 
    file { "/etc/systemd/system/${artifact}.service" :
      ensure  => file,
      content => template('springboot/systemd.service.erb'),
    }
    exec { 'create-delivery-server-service':
      command     => 'systemctl daemon-reload',
      path        => ['/bin','/sbin'],
      subscribe   => File["/etc/systemd/system/${artifact}.service"],
      refreshonly => true,
    }
    service { $artifact :
      ensure  => running,
      require => Exec['create-delivery-server-service'],
    }
  }

}
