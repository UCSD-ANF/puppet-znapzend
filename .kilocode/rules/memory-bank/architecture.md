# Architecture: puppet-znapzend

## Module Structure Overview

### Core Manifests (`/manifests/`)
- [`init.pp`](manifests/init.pp:88) - Main orchestration class with parameter validation and execution flow
- [`params.pp`](manifests/params.pp:3) - **DEPRECATED**: Legacy OS-specific parameter definitions (migrated to Hiera)
- [`install.pp`](manifests/install.pp:3) - Package, user, directory, and init script management
- [`service.pp`](manifests/service.pp:3) - Service resource definition and management
- [`config.pp`](manifests/config.pp:51) - Define for creating individual backup plan configurations
- [`plans.pp`](manifests/plans.pp:3) - Processes plans hash and creates config resources

### Hiera Data Layer (`/data/`)
- [`common.yaml`](data/common.yaml:1) - Default parameter values for all platforms
- [`os/FreeBSD.yaml`](data/os/FreeBSD.yaml:1) - FreeBSD-specific parameter overrides
- [`os/RedHat.yaml`](data/os/RedHat.yaml:1) - RedHat/CentOS-specific parameter overrides
- [`os/Solaris.yaml`](data/os/Solaris.yaml:1) - Solaris-specific parameter overrides
- [`hiera.yaml`](hiera.yaml:1) - Hiera v5 configuration with OS hierarchy

### Configuration Templates (`/templates/`)
**Dual Format Support - Both ERB and EPP formats maintained:**
- [`znapzend.conf.erb`](templates/znapzend.conf.erb:1) / [`znapzend.conf.epp`](templates/znapzend.conf.epp:1) - Backup plan configuration
- [`znapzend_sudo.erb`](templates/znapzend_sudo.erb:1) / [`znapzend_sudo.epp`](templates/znapzend_sudo.epp:1) - Sudo privileges with type safety
- [`znapzend_init_centos.erb`](templates/znapzend_init_centos.erb:1) / [`znapzend_init_centos.epp`](templates/znapzend_init_centos.epp:1) - SystemD service unit file
- [`znapzend_init_freebsd.erb`](templates/znapzend_init_freebsd.erb:1) / [`znapzend_init_freebsd.epp`](templates/znapzend_init_freebsd.epp:1) - FreeBSD rc.d startup script
- [`znapzend_init_solaris.erb`](templates/znapzend_init_solaris.erb:1) / [`znapzend_init_solaris.epp`](templates/znapzend_init_solaris.epp:1) - Solaris SMF method script
- [`znapzend.xml.erb`](templates/znapzend.xml.erb:1) / [`znapzend.xml.epp`](templates/znapzend.xml.epp:1) - Solaris SMF service manifest

### Test Framework (`/spec/`)
- [`spec_helper.rb`](spec/spec_helper.rb:1) - RSpec test configuration
- [`classes/znapzend_spec.rb`](spec/classes/znapzend_spec.rb:3) - Comprehensive cross-platform tests

### CI/CD Infrastructure (`/.github/workflows/`)
- [`release.yml`](.github/workflows/release.yml:1) - Automated release and Puppet Forge deployment
- Automated testing and quality assurance

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
2. **Init Script Deployment**: OS-specific service script creation using dual template format
3. **Sudo Configuration**: ZFS command privileges setup with type-safe EPP templates
4. **User/Group Management**: Optional dedicated backup user creation
5. **Directory Structure**: Creates log, PID, and configuration directories

### 3. Service Management (service.pp)
- Standard Puppet service resource with platform-agnostic interface
- Integrates with OS-specific init systems through deployed scripts

### 4. Configuration Workflow (config.pp + plans.pp)
1. **Plan Processing**: [`plans.pp`](manifests/plans.pp:4) uses `create_resources` to process plan hash
2. **Config File Generation**: [`config.pp`](manifests/config.pp:71) creates config files from templates (ERB or EPP)
3. **Plan Import**: Executes `znapzendzetup import` to load plans into znapzend
4. **Service Reload**: Automatically reloads daemon when configuration changes

## Modern Data Architecture

### Hiera v5 Data Hierarchy
**Lookup order defined in [`hiera.yaml`](hiera.yaml:8):**
1. **OS-specific major release**: `data/os/{OS.name}/{major}.yaml`
2. **OS family major release**: `data/os/{OS.family}/{major}.yaml`
3. **Kernel release**: `data/os/{OS.family}/{kernelrelease}.yaml` (Solaris)
4. **OS name**: `data/os/{OS.name}.yaml`
5. **OS family**: `data/os/{OS.family}.yaml`
6. **Common defaults**: `data/common.yaml`

### Parameter Migration from params.pp
**Old Architecture** (params.pp selector-based):
```puppet
$mbuffer_path = $::osfamily ? {
  'FreeBSD' => '/usr/local/bin',
  'Solaris' => '/opt/csw/bin',
  default   => '/usr/bin',
}
```

**New Architecture** (Hiera data-driven):
- [`data/common.yaml`](data/common.yaml:23): `znapzend::mbuffer_path: '/usr/bin'`
- [`data/os/FreeBSD.yaml`](data/os/FreeBSD.yaml:3): `znapzend::mbuffer_path: '/usr/local/bin'`
- [`data/os/Solaris.yaml`](data/os/Solaris.yaml:3): `znapzend::mbuffer_path: '/opt/csw/bin'`

## Template Architecture Evolution

### ERB Templates (Legacy)
- Traditional variable access via `scope.lookupvar()`
- No type validation
- Runtime error detection only

### EPP Templates (Modern)
**Type-safe parameter definitions:**
```epp
<%- | String[1] $user,
      Stdlib::Absolutepath $zfs_path,
      Stdlib::Absolutepath $mbuffer_path,
| -%>
```
- **Compile-time validation**: Parameter types checked during catalog compilation
- **Enhanced security**: Stronger input validation
- **Better debugging**: Clear parameter contracts

## Cross-Platform Architecture

### OS-Specific Data Management (Hiera-based)
- **Service Management**: Different reload commands for systemctl/svcadm/service
- **File Paths**: Varying locations for mbuffer, sudo, user shells, ZFS binaries
- **Package Management**: Conditional package installation (disabled on Solaris)

### Init System Implementations
- **RedHat/CentOS**: SystemD unit file [`/lib/systemd/system/znapzend.service`](templates/znapzend_init_centos.epp:1)
- **FreeBSD**: rc.d script [`/usr/local/etc/rc.d/znapzend`](templates/znapzend_init_freebsd.epp:1)
- **Solaris**: SMF method [`/lib/svc/method/znapzend`](templates/znapzend_init_solaris.epp:1) + manifest [`/var/svc/manifest/system/filesystem/znapzend.xml`](templates/znapzend.xml.epp:1)

## Security Architecture

### Privilege Separation
- **Dedicated User**: Optional `znapzend` user with minimal privileges
- **Type-safe Sudo Configuration**: Restricted to specific ZFS and mbuffer commands only
- **File Permissions**: Proper ownership and permissions on all directories

### Configuration Security
- Configuration files owned by znapzend user
- Sudo rules use NOPASSWD for automation but restrict command scope
- PID and log files isolated in dedicated directories

## Configuration Data Flow

### Input Processing
1. **Puppet Parameters**: Class parameters define global settings
2. **Hiera Data**: OS-specific parameter resolution through data hierarchy
3. **Plans Hash**: Contains backup plan definitions in structured format
4. **Template Variables**: EPP templates receive typed parameters with validation

### Config File Generation
1. **File Naming**: Config source path converted to filename (slashes → underscores)
2. **Template Rendering**: Dual format support - [`znapzend.conf.erb`](templates/znapzend.conf.erb:1) or [`znapzend.conf.epp`](templates/znapzend.conf.epp:1)
3. **Type Safety**: EPP templates provide parameter validation
4. **Import Execution**: `znapzendzetup import --write` loads config into znapzend
5. **Service Notification**: Configuration changes trigger service reload

## Validation and Error Handling

### Input Validation (init.pp lines 116-124)
- OS family compatibility checking (`RedHat|FreeBSD|Solaris`)
- Boolean parameter validation
- Package ensure value validation
- Hash structure validation for plans

### Enhanced Type Safety (EPP Templates)
- Compile-time parameter type checking
- Required vs optional parameter enforcement
- Path validation for file system paths
- String length validation for non-empty values

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

### 4. Hiera Data Resolution
[`hiera.yaml:9-20`](hiera.yaml:9) - OS-specific parameter hierarchy and lookup order

### 5. Template Type Safety
[`templates/znapzend_sudo.epp:1-4`](templates/znapzend_sudo.epp:1) - Type-safe EPP parameter definitions