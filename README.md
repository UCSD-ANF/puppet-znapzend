puppet-znapzend
==================

## Overview
Manage the [znapzend](http://www.znapzend.org/) package with Puppet 

## Requirements
 * ZFS on {CentOS,Solaris,FreeBSD}
 * SSH passwordless authentication enabled for SRC -> DST hosts (if DST is remote)
 * mbuffer (optional)

## ZnapZend plan parameters
Refer to [znapzendzetup](https://github.com/oetiker/znapzend/blob/master/doc/znapzendzetup.pod) for more detail on parameters this modules supports below (some params are specific to this module)

* `config_file` - The name of the configuration file used for a **znapzendzetup import**.

* `config_src` - ZFS _source_ fileystem for backup plan.

* `config_dst_a` - Backup destination "a". 

* `config_dst_a_plan` - The plan specifies how often and long to keep backups.  
   _Format_  
    `retA=>intA,retB=>intB,...`  
    _Example_  
    `1week=>30min` - will keep one copy every 30 minutes for 1 week

* `config_dst_b` - Backup destination "b".

* `config_dst_b_plan` - Backup plan for destination "b". Same format as `config_dst_a_plan`

* `config_enabled` - Defaults to **on**.  You may disable the backup plan with **off**.

* `config_mbuffer` - Path to mbuffer binary. A value of **off** will disable mbuffer (default)

* `config_mbuffer_size` - Specify the mbuffer size. Default is **1G**.  
   _Supports the following units_   
   `b, k, M, G`

* `config_post_znap_cmd` - Run commnad _after_ snapshot is taken.  Default is **off**.

* `config_pre_znap_cmd` - Run commnad _before_ snapshot is taken.  Default is **off**.

* `config_recursive` - Create snapshots of child ZFS file systems as well.  Default is **on**.

* `config_zend_delay` - Specify delay in seconds before sending snapshots to destination.


## Examples

