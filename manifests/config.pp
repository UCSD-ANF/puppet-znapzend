# == Class: znapzend::config
#
class znapzend::config {

  # directories
  file {
    $znapzend::service_pid_dir:
      ensure => 'directory',
      owner  => $znapzend::user,
      group  => $znapzend::group,
      mode   => '0755',;
    $znapzend::service_log_dir:
      ensure => 'directory',
      owner  => $znapzend::user,
      group  => $znapzend::group,
      mode   => '0755',;
    $znapzend::service_conf_dir:
      ensure => 'directory',
      owner  => $znapzend::user,
      group  => $znapzend::group,
      mode   => '0755',;
  }

  # conditional sudo
  if $znapzend::manage_sudo {
    file { "${znapzend::sudo_d_path}/znapzend":
      owner   => 'root',
      mode    => '0440',
      content => epp('znapzend/znapzend_sudo.epp'),
    }
  }

  # conditional add non-root user/group
  if $znapzend::manage_user and $znapzend::user != 'root' {
    group { $znapzend::group:
      ensure => 'present',
      system => true,
      before => File[$znapzend::service_pid_dir],
    }
    -> user { $znapzend::user:
      ensure     => 'present',
      comment    => 'ZnapZend Backup user',
      shell      => $znapzend::user_shell,
      home       => $znapzend::user_home,
      managehome => true,
      system     => true,
    }
  }

  if $znapzend::manage_init {
    # OS-specific init script(s)
    case $facts['os']['family'] {
      'FreeBSD': {
        file { "/usr/local/etc/rc.d/${znapzend::service_name}":
          ensure  => 'file',
          owner   => 'root',
          group   => 'wheel',
          mode    => '0555',
          content => epp('znapzend/znapzend_init_freebsd.epp'),
        }
      } 'RedHat': {
        file { '/lib/systemd/system/znapzend.service':
          ensure  => 'file',
          owner   => 'root',
          group   => 'root',
          mode    => '0644',
          content => epp('znapzend/znapzend_init_redhat.epp'),
        }
      } 'Solaris': {
        file {
          "/lib/svc/method/${znapzend::service_name}":
            ensure  => 'file',
            owner   => 'root',
            group   => 'bin',
            mode    => '0555',
            content => epp('znapzend/znapzend_init_solaris.epp'),;
          "/var/svc/manifest/system/filesystem/${znapzend::service_name}.xml":
            ensure  => 'file',
            owner   => 'root',
            group   => 'bin',
            mode    => '0555',
            content => epp('znapzend/znapzend.xml.epp'),
            notify  => Exec['reload-manifest'],;
        }
        exec { 'reload-manifest':
          refreshonly => true,
          command     => join([
            '/usr/sbin/svccfg import',
            "/var/svc/manifest/system/filesystem/${znapzend::service_name}.xml",
          ], ' '),
        }
      } default: {
        # NOOP
      }
    }
  }
}
