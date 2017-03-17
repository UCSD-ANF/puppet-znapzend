# == Class: znapzend::params
#
class znapzend::params {

  $user			  = "znapzend"
  $user_home              = "/home/$user"
  $service_name           = 'znapzend'
  $service_conf_dir       = "/usr/local/etc/$service_name"
  $service_log_dir        = "/var/log/$service_name"
  $service_log_file       = "$service_log_dir/$service_name.log"
  $service_pid_dir        = "/var/run/$service_name"
  $service_pid_file       = "$service_pid_dir/$service_name.pid"
  $service_start_options  = "--daemonize --features=sudo"

  $service_reload_cmd = $::osfamily ? {
    'RedHat'  => "systemctl reload $service_name",
    'Solaris'  => "svcadm refresh $service_name",
    default   => "service $service_name reload",
  }
  
  $user_shell = $::osfamily ? {
    'FreeBSD' => '/usr/local/bin/bash',
    default   => '/bin/bash',
  }

  $package_manage = $::osfamily ? {
    'Solaris'  => false,
    default    => true,
  }

  $sudo_d_path = $::osfamily ? {
    'FreeBSD'  => '/usr/local/etc/sudoers.d',
    default   => '/etc/sudoers.d'
  }
    
}
