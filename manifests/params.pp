# == Class: znapzend::params
#
class znapzend::params {

  $service_log_dir          = "/var/log/znapzend"
  $service_log_file         = "${service_log_dir}/znapzend.log"
  $service_pid_dir          = "/var/run/znapzend"
  $service_pid_file         = "${service_pid_dir}/znapzend.pid"
  $service_start_cmd        = "/usr/local/bin/znapzend"
  $service_start_options    = "--daemonize --features=sudo --pidfile=${service_pid_file} --logto=${service_log_file}"

  case $::osfamily {
    'RedHat': {
      $user_shell           = '/bin/bash'
      $service_reload_cmd   = 'systemctl reload znapzend'
    }
    'FreeBSD': {
      $config_file          = '/usr/local/etc/znapzend.conf'
      $service_reload_cmd   = 'service znapzend reload'
      $user_shell           = '/usr/local/bin/bash'
    }
  }

}
