# == Class: znapzend::params
#
class znapzend::params {

  $basedir                = '/usr/local/bin'
  $manage_user            = true
  $manage_sudo            = true
  $user			  = 'znapzend'
  $user_home              = "/home/$user"
  $user_uid               = '179'
  $user_gid               = '179'
  $group                  = 'znapzend'
  $package_ensure         = 'present'
  $package_name           = 'znapzend'
  $service_enable         = true
  $service_ensure         = 'running'
  $service_name           = 'znapzend'
  $service_conf_dir       = "/usr/local/etc/$service_name"
  $service_log_dir        = "/var/log/$service_name"
  $service_log_file       = "$service_log_dir/$service_name.log"
  $service_pid_dir        = "/var/run/$service_name"
  $service_pid_file       = "$service_pid_dir/$service_name.pid"
  $service_features       = "sudo"
  $service_hasstatus      = true

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
    'Solaris'  => '/etc/opt/csw/sudoers.d',
    default   => '/etc/sudoers.d'
  }
    
}
