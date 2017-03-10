# == Class: znapzend::config
#
class znapzend::config {

  # znapzend conf file
  file { $::znapzend::config_file:
    owner    => 'znapzend',
    group    => 'znapzend',
    mode     => '0755',
    content  => template('znapzend/znapzend.conf.erb'),
    notify   => Exec['load_znapzend_config'],
  }

  # reload the config with znapzend and reload the znapzend daemon
  exec { 'load_znapzend_config':
    command  => "/usr/local/bin/znapzendzetup import --write $znapzend::config_src < /usr/local/etc/znapzend.conf; $znapzend::service_reload_cmd",
    refreshonly => true,
  }

}
