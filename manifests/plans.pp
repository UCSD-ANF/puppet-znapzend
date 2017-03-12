# == Class: znapzend::plans
#
class znapzend::plans {

   define generate_config (
     $config_file,
     $config_src, 
     $config_dst_a           = undef,
     $config_dst_a_plan      = undef,
     $config_dst_b           = undef,
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
   ) {
    
       # create config file to be read by znapzendzetup
       file { "$znapzend::service_conf_dir/$config_file":
         owner     => 'znapzend',
         group     => 'znapzend',
         content  => template('znapzend/znapzend.conf.erb'),
         notify   => Exec["load_${config_file}"],
       }
       # reload the config with znapzend and reload the znapzend daemon
       exec { "load_${config_file}":
         command  => "/usr/local/bin/znapzendzetup import --write $config_src < $znapzend::service_conf_dir/$config_file; $znapzend::service_reload_cmd",
         refreshonly => true,
       }
   }

   create_resources ('generate_config', $::znapzend::plans)

}
