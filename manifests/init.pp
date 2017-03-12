# == Class: znapzend
#
# Manage znapzend for ZFS backup/replication
#
class znapzend (
  $basedir		  = '/usr/local/bin',
  $user                   = 'znapzend',
  $user_shell		  = $znapzend::params::user_shell,
  $group                  = 'znapzend',
  $package_ensure         = 'present',
  $package_manage         = true,
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
#  validate_re($::osfamily, '^(RedHat|FreeBSD)$', "OS Family ${::osfamily} unsupported")
  validate_re($package_ensure, '^(absent|latest|present|purged)$')
  validate_string($package_name)

  anchor {'::znapzend::begin': } ->
  class {'::znapzend::install': } ->
  class {'::znapzend::service': } ->
  class {'::znapzend::plans': } ->
  anchor {'::znapzend::end': }
}
