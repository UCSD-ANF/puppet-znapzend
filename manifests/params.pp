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

  $service_reload_cmd = $::osfamily ? {
    'RedHat'  => "systemctl reload $servicename",
    'Solaris'  => "svcadm refresh znapzend",
    default   => "service $servicename reload",
  }
  
  $user_shell = $::osfamily ? {
    'FreeBSD' => '/usr/local/bin/bash',
    default   => '/bin/bash',
  }

  $package_manage = $::osfamily ? {
    'Solaris'  => false,
    default    => true,
  }

}
