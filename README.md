puppet-znapzend
==================

## Overview
Manage the [znapzend](http://www.znapzend.org/) package with Puppet 

## Requirements
 * ZFS on {CentOS,Solaris,FreeBSD}
 * SSH passwordless authentication enabled for SRC -> DST hosts (if DST is remote)
 * mbuffer (optional)

## Examples
Run znapzend daemon as the _zfsbackup_ user
```
class 'znapzend' {
  user        => 'zfsbackup',
  group       => 'zfsbackup',
  manage_user => 'false',
}
```
Create a backup plan to take local snapshots every _10 minutes_ and keep them for _1 hour_.
```
znapzend::plans { 'tank':
  config_file     => 'zpool_tank',
  config_src      => 'zpool/tank',
  config_src_plan => '1hour=>10minutes',
}
```
Now send those snapshots to a remote host and rotate those snapshots every _4 hours_ for _1 day_.
```
znapzend::plans { 'tank':
  config_file     => 'zpool_tank',
  config_src      => 'zpool/tank',
  config_src_plan => '1hour=>10minutes',
  config_dst_a    => 'backupuser@remotehost.example.com:backuppool/tank_bak',
  config_dst_a_plan => '1day=>4hours',
}
```
