# Product Overview: puppet-znapzend

## What This Project Is
A comprehensive Puppet module that manages znapzend, a ZFS backup and replication daemon. Znapzend automates the creation of ZFS snapshots and their replication to local or remote destinations according to configurable retention policies.

## Problems It Solves

### 1. ZFS Backup Automation
- **Problem**: Manual ZFS snapshot management is error-prone and time-consuming
- **Solution**: Automated snapshot creation with configurable retention policies (e.g., "take snapshots every 10 minutes, keep for 1 hour")

### 2. Cross-Platform ZFS Management
- **Problem**: Different Unix systems (Linux, FreeBSD, Solaris) have different service management approaches
- **Solution**: Unified Puppet interface that handles OS-specific differences (systemd vs rc.d vs SMF)

### 3. Secure Remote Replication
- **Problem**: ZFS send/receive operations require root privileges, creating security challenges
- **Solution**: Dedicated backup user with minimal sudo privileges for ZFS operations only

### 4. Configuration Complexity
- **Problem**: znapzend configuration is complex with many parameters
- **Solution**: Declarative Puppet DSL for backup plans with validation and templates

## How It Works

### Installation Process
1. **Package Management**: Installs znapzend package (except Solaris where it's manual)
2. **User Setup**: Creates dedicated `znapzend` user and group for security
3. **Directory Structure**: Creates log, PID, and configuration directories with proper permissions
4. **Init Scripts**: Deploys OS-appropriate service startup scripts
5. **Sudo Configuration**: Sets up minimal ZFS command privileges

### Backup Plan Configuration
1. **Plan Definition**: Uses `znapzend::config` define to create backup plans
2. **Template Generation**: Creates configuration files from ERB templates
3. **Plan Import**: Uses `znapzendzetup import` to load plans into znapzend
4. **Service Reload**: Automatically reloads daemon when plans change

### Service Management
- **Daemon Control**: Standard service start/stop/restart/reload operations
- **Status Monitoring**: Health checks and PID file management  
- **Log Management**: Centralized logging with configurable locations

## User Experience Goals

### For System Administrators
- **Declarative Configuration**: Define backup strategies in Puppet manifests
- **Minimal Manual Intervention**: Automated setup and maintenance
- **Flexibility**: Support for both local and remote backup destinations
- **Reliability**: Robust error handling and service management

### Example Usage Patterns
```puppet
# Basic local backup
class 'znapzend' {
  user        => 'zfsbackup',
  group       => 'zfsbackup',
  manage_user => false,
}

# Backup plan with remote destination
znapzend::plans { 'tank':
  config_src        => 'zpool/tank',
  config_src_plan   => '1hour=>10minutes',
  config_dst_a      => 'backupuser@remote.example.com:backuppool/tank_bak',
  config_dst_a_plan => '1day=>4hours',
}
```

## Key Value Propositions
- **Automation**: Eliminates manual snapshot management tasks
- **Consistency**: Ensures backup policies are applied uniformly across infrastructure
- **Security**: Implements principle of least privilege for backup operations  
- **Portability**: Works across major Unix platforms with ZFS support
- **Integration**: Fits naturally into existing Puppet infrastructure workflows