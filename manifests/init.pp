# == Class: znapzend
#
# Manage znapzend for ZFS backup/replication
#
#
# === Parameters
#
# [*basedir*]
#   The base directory where ZnapZend is installed.  Defaults to /usr/local
#   by the package
#
# [*user*]
#   The user account the znapzend daemon should run under.  Defaults to 
#   'znapzend'
#
# [*user_shell*]
#   The shell defined for $user.  Defaults to 'bash'
#
# [*group*]
#   The group assigned to relevenat files and direcories.  Defaults to 
#   'znapzend'
#
# [*package_ensure*] 
#   Defaults to 'present'. Can be set to a specific version of znapzend,
#   or to 'latest' to ensure the package is always upgraded.   
#
# [*package_manage*]
#   If false, the package will not be managed by this class. Defaults to true.
#
# [*package_name*]
#   The name (or names) of the package to be installed. Defaults are
#    OS-specific but you may override them here.
#
# [*service_enable*]
#   Defaults to true. Defines if service should be enabled at startup.
#
# [*service_ensure*]
#   Defaults to running. Can be any valid value for the ensure parameter for a
#   service resource type.
#
# [*service_name*]
#   The name of the service(s) to manage. Defaults to 'znapzend'
#
# [*service_conf_dir*]
#   The directory where znapzend configuration files are stored.  Defaults to 
#   '/usr/local/etc/znapzend'.
#
# [*service_log_dir*]
#   The log directory for znapzend.  Defaults to '/var/log/znapzend'.
#
# [*service_log_file*]
#   The log file for znapzend.  Defaults to $service_log_dir/znapzend.log.
#
# [*service_pid_dir*]
#   The pid directory for the znapzend daemon.  Defaults to '/var/run/znapzend'.
#
# [*service_pid_file*]
#   The pid file for the znapzend daemon.  Defaults to $service_pid_dir/znapzend.pid'.
#
# [*service_reload_cmd*]
#   This command reloads the znapzend configuration.
#
# [*service_start_options*]
#   Additional argments that may send to the 'znapzend' command.  Refer to znapzend 
#   docs for additional options.  "daemonize, pidfile & logto" are required
#   and need not be specified here
#
# [*service_hasstatus*]
#   Defines whether the service supports the 'status' command.  Default is true.
#
# [*plans*]
#   This is a has array of snapshot plan schedule.  Usually defined in hieradata
#   More details can be found in the znapzend::plans class
#
class znapzend (
  $basedir		  = '/usr/local/bin',
  $manage_user            = true,
  $manage_sudo            = true,
  $user                   = $znapzend::params::user,
  $user_home              = $znapzend::params::user_home,
  $user_shell		  = $znapzend::params::user_shell,
  $user_uid               = '79',
  $group                  = 'znapzend',
  $sudo_d_path            = $znapzend::params::sudo_d_path,
  $package_ensure         = 'present',
  $package_manage         = $znapzend::params::package_manage,
  $package_name           = 'znapzend',
  $service_enable         = true,
  $service_ensure         = 'running',
  $service_name           = 'znapzend',
  $service_conf_dir	  = $znapzend::params::service_conf_dir,
  $service_log_dir        = $znapzend::params::service_log_dir,
  $service_log_file       = $znapzend::params::service_log_file,
  $service_pid_dir        = $znapzend::params::service_pid_dir,
  $service_pid_file       = $znapzend::params::service_pid_file,
  $service_reload_cmd     = $znapzend::params::service_reload_cmd,
  $service_start_options  = $znapzend::params::service_start_options,
  $service_hasstatus      = true,
  $plans		  = {},
) inherits znapzend::params {

  # validate OS
  validate_re($::osfamily, '^(RedHat|FreeBSD|Solaris)$', "OS Family ${::osfamily} unsupported")
  validate_re($package_ensure, '^(absent|latest|present)$')
  validate_bool($package_manage)
  validate_string($package_name)
  validate_bool($service_enable)

  anchor {'::znapzend::begin': } ->
  class {'::znapzend::install': } ->
  class {'::znapzend::service': } ->
  class {'::znapzend::plans': } ->
  anchor {'::znapzend::end': }
}
