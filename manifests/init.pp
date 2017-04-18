# == Class: znapzend
#
# Manage znapzend for ZFS backup/replication
#
#
# === Parameters
#
# [*basedir*]
#   The base directory where ZnapZend is installed.  Defaults to /opt/znapzend/bin
#
# [*manage_user*]
#   Defaults to true.  Defines whether a user should be created
#
# [*manage_sudo*]
#   Defaults to true.  Defines whether to add sudo entries for zfs
#
# [*user*]
#   The user account the znapzend daemon should run under.  Defaults to 
#   'znapzend'
#
# [*user_home*]
#    User home directory
#
# [*user_shell*]
#   The shell defined for $user.  Defaults to 'bash'
#
# [*group*]
#   The group assigned to relevant files and directories.  Defaults to 
#   'znapzend'
#
# [*sudo_d_path*]
#   Defines path to sudoers.d directory
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
# [*service_features*]
#   Comma separated list of "features" that may be passed to the 'znapzend' command. 
#   Valid features are: oracleMode,recvu,pfexec and sudo (default)
#
# [*service_hasstatus*]
#   Defines whether the service supports the 'status' command.  Default is true.
#
# [*plans*]
#   This is a hash array of snapshot plan schedule.  Usually defined in hieradata
#   More details can be found in the znapzend::plans class
#
class znapzend (
  $basedir		  = $znapzend::params::basedir,
  $manage_user            = $znapzend::params::manage_user,
  $manage_sudo            = $znapzend::params::manage_sudo,
  $user                   = $znapzend::params::user,
  $user_home              = $znapzend::params::user_home,
  $user_shell		  = $znapzend::params::user_shell,
  $group                  = $znapzend::params::group,
  $sudo_d_path            = $znapzend::params::sudo_d_path,
  $package_ensure         = $znapzend::params::package_ensure,
  $package_manage         = $znapzend::params::package_manage,
  $package_name           = $znapzend::params::package_name,
  $service_enable         = $znapzend::params::service_enable,
  $service_ensure         = $znapzend::params::service_ensure,
  $service_name           = $znapzend::params::service_name,
  $service_conf_dir	  = $znapzend::params::service_conf_dir,
  $service_log_dir        = $znapzend::params::service_log_dir,
  $service_log_file       = $znapzend::params::service_log_file,
  $service_pid_dir        = $znapzend::params::service_pid_dir,
  $service_pid_file       = $znapzend::params::service_pid_file,
  $service_reload_cmd     = $znapzend::params::service_reload_cmd,
  $service_features       = $znapzend::params::service_features,
  $service_hasstatus      = $znapzend::params::service_hasstatus,
  $plans		  = {},
) inherits znapzend::params {

  validate_re($::osfamily, '^(RedHat|FreeBSD|Solaris)$', "OS Family ${::osfamily} unsupported")
  validate_bool($manage_user)
  validate_bool($manage_sudo)
  validate_re($package_ensure, '^(absent|latest|present)$')
  validate_bool($package_manage)
  validate_string($package_name)
  validate_bool($service_enable)
  validate_bool($service_hasstatus)
  validate_hash($plans)


  anchor {'::znapzend::begin': } ->
  class {'::znapzend::install': } ->
  class {'::znapzend::service': } ->
  class {'::znapzend::plans': } ->
  anchor {'::znapzend::end': }
}
