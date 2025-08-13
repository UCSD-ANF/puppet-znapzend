# == Class: znapzend::install
#
class znapzend::install {
  if $znapzend::package_manage {
    package { $znapzend::package_name:
      ensure => $znapzend::package_ensure,
      name   => $znapzend::package_name,
    }
  }

  # init script(s)
  case $facts['os']['family'] {
    'FreeBSD': {
      file { "/usr/local/etc/rc.d/${znapzend::service_name}":
        owner   => 'root',
        group   => 'wheel',
        mode    => '0755',
        content => epp('znapzend/znapzend_init_freebsd.epp', {
            'service_name'     => $znapzend::service_name,
            'service_pid_file' => $znapzend::service_pid_file,
            'service_log_file' => $znapzend::service_log_file,
            'basedir'          => $znapzend::basedir,
            'user'             => $znapzend::user,
            'service_features' => $znapzend::service_features,
        }),
        notify  => Service[$znapzend::service_name],
      }
    }
    'RedHat': {
      file { '/lib/systemd/system/znapzend.service':
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
        content => epp('znapzend/znapzend_init_centos.epp', {
            'user'             => $znapzend::user,
            'basedir'          => $znapzend::basedir,
            'service_features' => $znapzend::service_features,
            'service_pid_file' => $znapzend::service_pid_file,
            'service_log_file' => $znapzend::service_log_file,
        }),
        notify  => Service[$znapzend::service_name],
      }
    }
    'Solaris': {
      file { "/lib/svc/method/${znapzend::service_name}":
        owner   => 'root',
        group   => 'bin',
        mode    => '0555',
        content => epp('znapzend/znapzend_init_solaris.epp', {
            'basedir'          => $znapzend::basedir,
            'service_pid_file' => $znapzend::service_pid_file,
            'service_log_file' => $znapzend::service_log_file,
            'service_name'     => $znapzend::service_name,
            'user'             => $znapzend::user,
            'service_features' => $znapzend::service_features,
        }),
        notify  => Service[$znapzend::service_name],
      }
      file { "/var/svc/manifest/system/filesystem/${znapzend::service_name}.xml":
        owner   => 'root',
        group   => 'bin',
        mode    => '0555',
        content => epp('znapzend/znapzend.xml.epp', {
            'service_name'     => $znapzend::service_name,
            'service_log_file' => $znapzend::service_log_file,
        }),
        notify  => Exec['reload-manifest'],
      }
      exec { 'reload-manifest':
        command     => "/usr/sbin/svccfg import /var/svc/manifest/system/filesystem/${znapzend::service_name}.xml",
        refreshonly => true,
      }
    }
    default: {
      fail("Unsupported OS family: ${facts['os']['family']}. This module supports RedHat, FreeBSD, and Solaris only.")
    }
  }

  # manage sudo
  if $znapzend::manage_sudo {
    file { "${znapzend::sudo_d_path}/znapzend":
      owner   => 'root',
      mode    => '0440',
      content => epp('znapzend/znapzend_sudo.epp', {
          'user'         => $znapzend::user,
          'zfs_path'     => $znapzend::zfs_path,
          'mbuffer_path' => $znapzend::mbuffer_path,
      }),
    }
  }

  # add non-root user/group if specified
  if $znapzend::user != 'root' {
    if $znapzend::manage_user {
      group { $znapzend::group:
        ensure => 'present',
      }
      -> user { $znapzend::user:
        ensure  => 'present',
        comment => 'znapzend backup user',
        shell   => $znapzend::user_shell,
        home    => $znapzend::user_home,
      }
    }
  }
  # pid dir
  file { $znapzend::service_pid_dir:
    ensure  => 'directory',
    owner   => $znapzend::user,
    group   => $znapzend::group,
    mode    => '0644',
    recurse => true,
  }
  # log dir
  -> file { $znapzend::service_log_dir:
    ensure => 'directory',
    owner  => $znapzend::user,
    group  => $znapzend::group,
    mode   => '0755',
  }
  # config dir
  -> file { $znapzend::service_conf_dir:
    ensure => 'directory',
    owner  => $znapzend::user,
    group  => $znapzend::group,
    mode   => '0755',
  }
}
