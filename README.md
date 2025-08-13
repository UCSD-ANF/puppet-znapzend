# puppet-znapzend

[![Puppet Forge](https://img.shields.io/puppetforge/v/igpp/znapzend.svg)](https://forge.puppet.com/igpp/znapzend)
[![Puppet Forge - downloads](https://img.shields.io/puppetforge/dt/igpp/znapzend.svg)](https://forge.puppet.com/igpp/znapzend)
[![Puppet Forge - scores](https://img.shields.io/puppetforge/f/igpp/znapzend.svg)](https://forge.puppet.com/igpp/znapzend)

## Overview

A comprehensive Puppet module for managing [znapzend](http://www.znapzend.org/), a ZFS backup and replication daemon that automates snapshot creation and replication according to configurable retention policies.

This module provides complete lifecycle management of znapzend across multiple Unix-like platforms with cross-platform compatibility for different init systems.

## Requirements

### System Requirements
- **ZFS filesystem support** on target systems
- **Supported Operating Systems:**
  - CentOS/RHEL 7, 8, 9
  - FreeBSD 12, 13, 14  
  - Solaris 11
- **SSH passwordless authentication** enabled for remote backup destinations
- **mbuffer** (optional, for improved transfer performance)

### Puppet Requirements
- **Puppet:** 6.21.0 to < 9.0.0
- **puppetlabs/stdlib:** >= 6.0.0 < 10.0.0

## Installation

Install from Puppet Forge:

```bash
puppet module install igpp-znapzend
```

Or add to your Puppetfile:

```puppet
mod 'igpp-znapzend', '2.0.0'
```

## Usage

### Basic Usage

Run znapzend daemon with default settings:

```puppet
include znapzend
```

### Custom User Configuration

Run znapzend daemon as a custom user:

```puppet
class { 'znapzend':
  user        => 'zfsbackup',
  group       => 'zfsbackup', 
  manage_user => false,
}
```

### Simple Local Backup Plan

Create a backup plan for local snapshots every 10 minutes, kept for 1 hour:

```puppet
znapzend::config { 'tank':
  config_src      => 'zpool/tank',
  config_src_plan => '1hour=>10minutes',
}
```

### Remote Backup with Retention

Send snapshots to a remote host with different retention policies:

```puppet
znapzend::config { 'tank':
  config_src        => 'zpool/tank',
  config_src_plan   => '1hour=>10minutes',
  config_dst_a      => 'backupuser@remotehost.example.com:backuppool/tank_bak',
  config_dst_a_plan => '1day=>4hours',
}
```

### Alternative: Using Plans Hash Parameter

You can also define backup plans using the `plans` hash parameter:

```puppet
class { 'znapzend':
  plans => {
    'tank' => {
      'config_src'        => 'zpool/tank',
      'config_src_plan'   => '1hour=>10minutes',
      'config_dst_a'      => 'backupuser@remotehost.example.com:backuppool/tank_bak',
      'config_dst_a_plan' => '1day=>4hours',
    },
  },
}
```

### Advanced Configuration

```puppet
class { 'znapzend':
  package_ensure     => 'latest',
  service_enable     => true,
  service_ensure     => 'running',
  manage_user        => true,
  manage_sudo        => true,
  user              => 'znapzend',
  group             => 'znapzend',
  service_log_dir   => '/var/log/znapzend',
  service_conf_dir  => '/usr/local/etc/znapzend',
  service_features  => 'oracleMode,recvu,sudo',
  plans             => {
    'tank' => {
      'config_src'      => 'zpool/tank',
      'config_src_plan' => '1hour=>10minutes',
    },
    'data' => {
      'config_src'        => 'zpool/data', 
      'config_src_plan'   => '1day=>1hour',
      'config_dst_a'      => 'backup@remote.example.com:backup/data',
      'config_dst_a_plan' => '1week=>1day',
    },
  },
}
```

## Parameters

### Main Class Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `basedir` | `Stdlib::Absolutepath` | `/opt/znapzend/bin` | Base directory where znapzend is installed |
| `manage_user` | `Boolean` | `true` | Whether to create the znapzend user |
| `manage_sudo` | `Boolean` | `true` | Whether to manage sudo entries for ZFS commands |
| `user` | `String[1]` | `znapzend` | User account for the znapzend daemon |
| `group` | `String[1]` | `znapzend` | Group for znapzend files and directories |
| `package_ensure` | `Enum['absent','latest','present']` | `present` | Package installation state |
| `package_manage` | `Boolean` | `true` | Whether to manage the znapzend package |
| `service_enable` | `Boolean` | `true` | Whether to enable the service at boot |
| `service_ensure` | `Stdlib::Ensure::Service` | `running` | Service state |
| `service_features` | `String[1]` | `sudo` | Comma-separated features (oracleMode,recvu,pfexec,sudo) |
| `plans` | `Hash` | `{}` | Hash of backup plan configurations |

### Backup Plan Parameters (`znapzend::plans`)

| Parameter | Type | Description |
|-----------|------|-------------|
| `config_src` | `String[1]` | Source ZFS dataset path |
| `config_src_plan` | `String[1]` | Source retention plan (e.g., '1hour=>10minutes') |
| `config_dst_a` | `Optional[String[1]]` | Primary destination (local path or user@host:path) |
| `config_dst_a_plan` | `Optional[String[1]]` | Primary destination retention plan |
| `config_dst_b` | `Optional[String[1]]` | Secondary destination |
| `config_dst_b_plan` | `Optional[String[1]]` | Secondary destination retention plan |

## Development

This module is built using the [Puppet Development Kit (PDK)](https://puppet.com/docs/pdk/2.x/pdk.html).

### Development Workflow

```bash
# Validate the module
pdk validate

# Run unit tests
pdk test unit

# Run syntax checks  
pdk validate syntax

# Run metadata validation
pdk validate metadata

# Convert legacy ERB templates to EPP (if needed)
pdk convert --template-url https://github.com/puppetlabs/pdk-templates
```

### Testing

Run the full test suite:

```bash
pdk test unit --verbose
```

Run specific test classes:

```bash
pdk test unit --tests=spec/classes/znapzend_spec.rb
```

### Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b my-new-feature`)
3. Make your changes following PDK best practices
4. Add tests for any new functionality
5. Run `pdk validate` and `pdk test unit`
6. Commit your changes (`git commit -am 'Add some feature'`)
7. Push to the branch (`git push origin my-new-feature`)
8. Create a Pull Request

## Changelog

See [CHANGELOG.md](CHANGELOG.md) for version history and breaking changes.

## Upgrade Guide

### Upgrading from 1.x to 2.0.0

Version 2.0.0 includes significant modernization with breaking changes:

**Breaking Changes:**
- **Minimum Puppet version:** Now requires Puppet 6.21.0+ (was 3.8.5)
- **stdlib dependency:** Now requires puppetlabs/stdlib >= 6.0.0 (was any version)
- **Template format:** Converted from ERB to EPP templates
- **Parameter validation:** Strict data type validation now enforced at compile time
- **Removed legacy Puppet 3.x compatibility code**

**Migration Steps:**
1. Upgrade Puppet to 6.21.0 or higher
2. Upgrade puppetlabs/stdlib to 6.0.0 or higher  
3. Test your existing configurations - most should work without changes
4. Update any custom templates if you were overriding them

**New Features in 2.0.0:**
- Modern Puppet data types with compile-time validation
- EPP template engine with better performance
- PDK-based module structure with improved testing
- Enhanced cross-platform support
- Better error messages and parameter validation

## License

Apache License 2.0 - see [LICENSE](LICENSE) file for details.

## Support

- **GitHub Issues:** [https://github.com/IGPP/puppet-znapzend/issues](https://github.com/IGPP/puppet-znapzend/issues)
- **Puppet Forge:** [https://forge.puppet.com/igpp/znapzend](https://forge.puppet.com/igpp/znapzend)

## Authors

- UC Regents
- Contributors listed in [CHANGELOG.md](CHANGELOG.md)
