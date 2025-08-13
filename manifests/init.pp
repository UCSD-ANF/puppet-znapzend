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
# [*mbuffer_path*]
#   This is the _local_ mbuffer path.  Defaults by OS in module hiera data.
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
# [*zfs_path*]
#   Path to the ZFS binary.  Defaults are OS-specific.
#
class znapzend (
  Stdlib::Absolutepath $basedir,
  Stdlib::Absolutepath $mbuffer_path,
  Boolean $manage_user,
  Boolean $manage_sudo,
  String[1] $user,
  Stdlib::Absolutepath $user_home,
  Stdlib::Absolutepath $user_shell,
  String[1] $group,
  Stdlib::Absolutepath $sudo_d_path,
  Enum['absent','latest','present'] $package_ensure,
  Boolean $package_manage,
  String[1] $package_name,
  Boolean $service_enable,
  Stdlib::Ensure::Service $service_ensure,
  String[1] $service_name,
  Stdlib::Absolutepath $service_conf_dir,
  Stdlib::Absolutepath $service_log_dir,
  Stdlib::Absolutepath $service_log_file,
  Stdlib::Absolutepath $service_pid_dir,
  Stdlib::Absolutepath $service_pid_file,
  String[1] $service_reload_cmd,
  String[1] $service_features,
  Boolean $service_hasstatus,
  Stdlib::Absolutepath $zfs_path,
  Hash $plans = {},
) {
  # Validate OS family compatibility
  unless $facts['os']['family'] in ['RedHat', 'FreeBSD', 'Solaris'] {
    fail("OS Family ${facts['os']['family']} unsupported")
  }

  # Class containment and ordering
  contain znapzend::install
  contain znapzend::service
  contain znapzend::plans

  Class['znapzend::install']
  -> Class['znapzend::service']
  -> Class['znapzend::plans']
}
