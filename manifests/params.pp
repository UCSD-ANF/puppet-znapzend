# == Class: znapzend::params
#
class znapzend::params {

  $service_name           = 'znapzend'
  $service_conf_dir       = "/usr/local/etc/$service_name"
  $service_log_dir        = "/var/log/$service_name"
  $service_log_file       = "$service_log_dir/$service_name.log"
  $service_pid_dir        = "/var/run/$service_name"
  $service_pid_file       = "$service_pid_dir/$service_name.pid"
  $service_start_options  = "--daemonize --features=sudo"

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
