# == Class: znapzend::install
#
class znapzend::install {
  if $::znapzend::package_name {
    package { 'znapzend' :
      ensure   => $::znapzend::package_ensure,
      name     => $::znapzend::package_name,
    }
  }

  # init and sudo script(s)
  case $::osfamily {
    'FreeBSD': {
        file { "/usr/local/etc/rc.d/$::znapzend::service_name":
          owner  => 'root',
          group  => 'wheel',
          mode   => '0755',
          content  => template('znapzend/znapzend_init_freebsd.erb'),
        }
    }
    'RedHat': {
        file { '/lib/systemd/system/znapzend.service':
          owner  => 'root',
          group  => 'root',
          mode   => '0755',
          content  => template('znapzend/znapzend_init_centos.erb'),
        }
        file { '/etc/sudoers.d/zfs':
          owner  => 'root',
          group  => 'root',
          mode   => '0755',
          source => 'puppet:///modules/znapzend/zfs_sudo',
        }
    }
  }

  # add znapzend user
  user { 'znapzend':
    ensure   => 'present',
    uid      => '79',
    comment  => 'znapzend backup user',
    shell    => $::znapzend::user_shell,
    home     => '/home/znapzend',
  } ->
  # pid dir
  file { '/var/run/znapzend':
    ensure   => 'directory',
    owner    => 'znapzend',
    group    => 'znapzend',
    mode     => '0755',
  } ->
  # log dir
  file { '/var/log/znapzend':
    ensure   => 'directory',
    owner    => 'znapzend',
    group    => 'znapzend',
    mode     => '0755',
  }


}
