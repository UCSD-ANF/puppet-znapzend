# == Define: znapzend::plan
#
# Apply config for znapzend backup plans
#
# Plans are setup using the 'znapzendzetup' command which
# 'imports' the config from $service_conf_dir.
#
# ===Parameters
#
# [*config_src*]
#   ZFS source filesystem for backup plan.
#
# [*config_dst_a*]
#   Backup destination "a".
#
# [*config_dst_a_plan*]
#   The plan specifies how often and how long to keep backups. It should follow
#   the format of:
#       retA=>intA,retB=>intB,...
#   Example ->
#       1week=>30min  # will keep one copy every 30 minutes for 1 week
#
# [*config_dst_b*]
#   Backup destination "b".
#
# [*config_dst_b_plan*]
#   Backup plan for destination "b", see above for examples (same as dst_a)
#
# [*config_enabled*]
#   Defaults to 'on'.  You may disable the backup plan with 'off'.
#
# [*config_mbuffer*]
#   Path to mbuffer binary.  A value of 'off' will dsiable mbuffer (default)
#
# [*config_mbuffer_size*]
#   Specify the mbuffer size. Default is 1G. Supports the following units:
#       b, k, M, G
#
# [*config_post_znap_cmd*]
#   Run command after snapshot is taken.  Default is 'off'.
#
# [*config_pre_znap_cmd*]
#   Run command before snapshot is taken.  Default is 'off'.
#
# [*config_recursive*]
#   Create snapshots of child ZFS file systems as well.  Default is 'on'.
#
# [*config_zend_delay*]
#   Specify delay in seconds before sending snapshots to destination.
#
define znapzend::plan(
  String $config_src = $name,
  String $config_src_plan = '1day=>1hour,1mon=>1day',
  Enum['on','off'] $config_enabled = 'on',
  Enum['on','off'] $config_mbuffer = 'off',
  String $config_mbuffer_size = '1G',
  String $config_post_znap_cmd = 'off',
  String $config_pre_znap_cmd = 'off',
  Enum['on','off'] $config_recursive = 'on',
  String $config_tsformat = '%Y-%m-%d-%H%M%S',
  Integer $config_zend_delay = 0,
  Optional[String] $config_dst_a = undef,
  Optional[String] $config_dst_a_plan = undef,
  Optional[String] $config_dst_b = undef,
  Optional[String] $config_dst_b_plan = undef,
) {
  include znapzend

  # create config file to be read by znapzendzetup
  $config_file = regsubst($config_src,'/','_','G')

  file { "${znapzend::service_conf_dir}/${config_file}":
    owner   => $znapzend::user,
    group   => $znapzend::group,
    content => template('znapzend/znapzend.conf.erb'),
    notify  => Exec["load_${config_file}"],
  }
  # reload the config with znapzend and reload the znapzend daemon
  exec { "load_${config_file}":
    refreshonly => true,
    command     => join([
      "${znapzend::basedir}/znapzendzetup import --write ${config_src}",
      "< ${znapzend::service_conf_dir}/${config_file};",
      $znapzend::service_reload_cmd,
    ], ' '),
    subscribe   => Class['znapzend::service'],
  }
}
