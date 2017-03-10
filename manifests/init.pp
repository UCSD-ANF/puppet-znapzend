# == Class: znapzend
#
# Manage znapzend for ZFS backup/replication
#
class znapzend (
  $package_ensure         = 'present',
  $package_manage         = true,
  $package_name           = 'znapzend',
  $service_enable         = true,
  $service_ensure         = 'running',
  $service_name           = 'znapzend',
  $service_log_dir        = $znapzend::params::service_log_dir,
  $service_log_file       = $znapzend::params::service_log_file,
  $service_pid_dir        = $znapzend::params::service_pid_dir,
  $service_pid_file       = $znapzend::params::service_pid_file,
  $service_reload_cmd     = $znapzend::params::service_reload_cmd,
  $service_start_cmd      = $znapzend::params::service_start_cmd,
  $service_start_options  = $znapzend::params::service_start_options,
  $service_hasstatus      = true,
  $user_shell		  = $znapzend::params::user_shell,
  $config_file            = '/usr/local/etc/znapzend.conf',
  $config_dst_a		  = undef,
  $config_dst_a_plan      = undef,
  $config_dst_b		  = undef,
  $config_dst_b_plan      = undef,
  $config_enabled         = 'on',
  $config_mbuffer         = 'off',
  $config_mbuffer_size    = '1G',
  $config_post_znap_cmd   = 'off',
  $config_pre_znap_cmd    = 'off',
  $config_recursive       = 'on',
  $config_src             = undef,
  $config_src_plan        = undef,
  $config_tsformat        = '%Y-%m-%d-%H%M%S',
  $config_zend_delay      = 0,
) inherits znapzend::params {

  # validate OS
#  validate_re($::osfamily, '^(RedHat|FreeBSD)$', "OS Family ${::osfamily} unsupported")
  validate_re($package_ensure, '^(absent|latest|present|purged)$')
  validate_string($package_name)

  anchor {'::znapzend::begin': } ->
  class {'::znapzend::install': } ->
  class {'::znapzend::service': } ->
  class {'::znapzend::config': } ->
  anchor {'::znapzend::end': }
}
