# == Class: znapzend::install
#
class znapzend::install {
  if $::znapzend::package_manage {
    package { $::znapzend::package_name :
      ensure   => $::znapzend::package_ensure,
      name     => $::znapzend::package_name,
    }
  }

  # init and sudo script(s)
  case $::osfamily {
    'FreeBSD': {
        file { "/usr/local/etc/rc.d/$::znapzend::service_name":
          owner    => 'root',
          group    => 'wheel',
          mode     => '0755',
          content  => template('znapzend/znapzend_init_freebsd.erb'),
        }
    }
    'RedHat': {

        exec { 'reload-sysctl-daemon':
          command     => "/bin/systemctl daemon-reload",
          refreshonly => true,
        }
        file { '/lib/systemd/system/znapzend.service':
          owner     => 'root',
          group     => 'root',
          mode      => '0755',
          content   => template('znapzend/znapzend_init_centos.erb'),
          notify    => Exec['reload-sysctl-daemon'],
        }
        file { '/etc/sudoers.d/zfs':
          owner  => 'root',
          group  => 'root',
          mode   => '0755',
          source => 'puppet:///modules/znapzend/zfs_sudo',
        }
    }
    'Solaris': {
        file { "/lib/svc/method/$::znapzend::service_name":
          owner    => 'root',
          group    => 'bin',
          mode     => '0555',
          content  => template('znapzend/znapzend_init_solaris.erb'),
        }
        file { "/var/svc/manifest/system/filesystem/${::znapzend::service_name}.xml":
          owner    => 'root',
          group    => 'bin',
          mode     => '0555',
          content  => template('znapzend/znapzend.xml.erb'),
          notify   => Exec['reload-manifest'],
        }
        exec { 'reload-manifest':
          command      => "/usr/sbin/svccfg import /var/svc/manifest/system/filesystem/${::znapzend::service_name}.xml",
          refreshonly => true, 
        }
    }
  }

  # add non-root user if specified 
  if $::znapzend::user != 'root' {
    user { $::znapzend::user:
      ensure   => 'present',
      uid      => '79',
      comment  => 'znapzend backup user',
      shell    => $::znapzend::user_shell,
      home     => '/home/znapzend',
    } 
  } 
  # pid dir
  file { $::znapzend::service_pid_dir:
    ensure   => 'directory',
    owner    => $::znapzend::user,
    group    => $::znapzend::group,
    mode     => '0755',
  } ->
  # log dir
  file { $::znapzend::service_log_dir:
    ensure   => 'directory',
    owner    => $::znapzend::user,
    group    => $::znapzend::group,
    mode     => '0755',
  } ->
  # config dir
  file { $::znapzend::service_conf_dir:
    ensure   => 'directory',
    owner    => $::znapzend::user,
    group    => $::znapzend::group,
    mode     => '0755',
  } 
  


}
