# == Class: znapzend::install
#
class znapzend::install {
  if $::znapzend::package_manage {
    package { $::znapzend::package_name :
      ensure   => $::znapzend::package_ensure,
      name     => $::znapzend::package_name,
    }
  }

  # init script(s)
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

  # manage sudo
  if $::znapzend::manage_sudo {
    file { "$::znapzend::sudo_d_path/znapzend":
          owner  => 'root',
          mode   => '0755',
          content => template('znapzend/znapzend_sudo.erb'),
        }
  }

  # add non-root user/group if specified 
  if $::znapzend::user != 'root' {
    if $::znapzend::manage_user {
      group { $::znapzend::group:
        ensure   => 'present',
        gid      => $::znapzend::user_gid,
      } ->
      user { $::znapzend::user:
        ensure   => 'present',
        uid      => $::znapzend::user_uid,
        gid      => $::znapzend::user_gid,
        comment  => 'znapzend backup user',
        shell    => $::znapzend::user_shell,
        home     => $::znapzend::user_home,
      } 
    }
  } 
  # pid dir
  file { $::znapzend::service_pid_dir:
    ensure   => 'directory',
    owner    => $::znapzend::user,
    group    => $::znapzend::group,
    mode     => '0644',
    recurse  => true,
  } ->
  # log dir
  file { $::znapzend::service_log_dir:
    ensure   => 'directory',
    owner    => $::znapzend::user,
    group    => $::znapzend::group,
    mode     => '0755',
    recurse  => true,
  } ->
  # config dir
  file { $::znapzend::service_conf_dir:
    ensure   => 'directory',
    owner    => $::znapzend::user,
    group    => $::znapzend::group,
    mode     => '0755',
    recurse  => true,
  } 
  


}
