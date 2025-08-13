# Architecture: puppet-znapzend

## Module Structure Overview

### Core Manifests (`/manifests/`)
- [`init.pp`](manifests/init.pp:88) - Main orchestration class with parameter validation and execution flow
- [`params.pp`](manifests/params.pp:3) - OS-specific parameter definitions and defaults
- [`install.pp`](manifests/install.pp:3) - Package, user, directory, and init script management
- [`service.pp`](manifests/service.pp:3) - Service resource definition and management
- [`config.pp`](manifests/config.pp:51) - Define for creating individual backup plan configurations
- [`plans.pp`](manifests/plans.pp:3) - Processes plans hash and creates config resources

### Configuration Templates (`/templates/`)
- [`znapzend.conf.erb`](templates/znapzend.conf.erb:1) - Backup plan configuration template
- [`znapzend_sudo.erb`](templates/znapzend_sudo.erb:1) - Sudo privileges template for ZFS commands
- [`znapzend_init_centos.erb`](templates/znapzend_init_centos.erb:1) - SystemD service unit file
- [`znapzend_init_freebsd.erb`](templates/znapzend_init_freebsd.erb:1) - FreeBSD rc.d startup script
- [`znapzend_init_solaris.erb`](templates/znapzend_init_solaris.erb:1) - Solaris SMF method script
- [`znapzend.xml.erb`](templates/znapzend.xml.erb:1) - Solaris SMF service manifest

### Test Framework (`/spec/`)
- [`spec_helper.rb`](spec/spec_helper.rb:1) - RSpec test configuration
- [`classes/znapzend_spec.rb`](spec/classes/znapzend_spec.rb:3) - Comprehensive cross-platform tests

## Execution Flow Architecture

### 1. Class Orchestration (init.pp)
```puppet
anchor {'::znapzend::begin': } ->
class {'::znapzend::install': } ->
class {'::znapzend::service': } ->
class {'::znapzend::plans': } ->
anchor {'::znapzend::end': }
```

### 2. Installation Phase (install.pp)
1. **Package Management**: Conditional package installation (skipped on Solaris)
2. **Init Script Deployment**: OS-specific service script creation
3. **Sudo Configuration**: ZFS command privileges setup
4. **User/Group Management**: Optional dedicated backup user creation
5. **Directory Structure**: Creates log, PID, and configuration directories

### 3. Service Management (service.pp)
- Standard Puppet service resource with platform-agnostic interface
- Integrates with OS-specific init systems through deployed scripts

### 4. Configuration Workflow (config.pp + plans.pp)
1. **Plan Processing**: [`plans.pp`](manifests/plans.pp:4) uses `create_resources` to process plan hash
2. **Config File Generation**: [`config.pp`](manifests/config.pp:71) creates config files from templates
3. **Plan Import**: Executes `znapzendzetup import` to load plans into znapzend
4. **Service Reload**: Automatically reloads daemon when configuration changes

## Cross-Platform Architecture

### OS-Specific Parameters (params.pp)
- **Service Management**: Different reload commands for systemctl/svcadm/service
- **File Paths**: Varying locations for mbuffer, sudo, user shells, ZFS binaries
- **Package Management**: Conditional package installation (disabled on Solaris)

### Init System Implementations
- **RedHat/CentOS**: SystemD unit file [`/lib/systemd/system/znapzend.service`](templates/znapzend_init_centos.erb:1)
- **FreeBSD**: rc.d script [`/usr/local/etc/rc.d/znapzend`](templates/znapzend_init_freebsd.erb:1)
- **Solaris**: SMF method [`/lib/svc/method/znapzend`](templates/znapzend_init_solaris.erb:1) + manifest [`/var/svc/manifest/system/filesystem/znapzend.xml`](templates/znapzend.xml.erb:1)

## Security Architecture

### Privilege Separation
- **Dedicated User**: Optional `znapzend` user with minimal privileges
- **Sudo Configuration**: Restricted to specific ZFS and mbuffer commands only
- **File Permissions**: Proper ownership and permissions on all directories

### Configuration Security
- Configuration files owned by znapzend user
- Sudo rules use NOPASSWD for automation but restrict command scope
- PID and log files isolated in dedicated directories

## Configuration Data Flow

### Input Processing
1. **Puppet Parameters**: Class parameters define global settings
2. **Plans Hash**: Contains backup plan definitions in structured format
3. **Template Variables**: ERB templates receive configuration via scope variables

### Config File Generation
1. **File Naming**: Config source path converted to filename (slashes → underscores)
2. **Template Rendering**: [`znapzend.conf.erb`](templates/znapzend.conf.erb:1) generates plan-specific config files
3. **Import Execution**: `znapzendzetup import --write` loads config into znapzend
4. **Service Notification**: Configuration changes trigger service reload

## Validation and Error Handling

### Input Validation (init.pp lines 116-124)
- OS family compatibility checking (`RedHat|FreeBSD|Solaris`)
- Boolean parameter validation
- Package ensure value validation
- Hash structure validation for plans

### Dependency Management
- Proper resource ordering through anchors
- Service notifications on configuration changes
- Directory creation before file placement
- User/group creation before directory ownership

## Critical Implementation Paths

### 1. Cross-Platform Service Management
[`manifests/install.pp:12-52`](manifests/install.pp:12) - OS detection and appropriate init script deployment

### 2. Configuration Import Workflow  
[`manifests/config.pp:77-81`](manifests/config.pp:77) - Configuration file creation → znapzendzetup import → service reload

### 3. Security Implementation
[`manifests/install.pp:54-61`](manifests/install.pp:54) - Sudo configuration with minimal required privileges

### 4. Parameter Inheritance
[`manifests/params.pp:24-55`](manifests/params.pp:24) - OS-specific parameter selection using Puppet selector syntax