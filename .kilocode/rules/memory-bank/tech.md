# Technologies & Development Setup: puppet-znapzend

## Core Technologies

### Primary Technologies
- **Puppet**: Configuration management framework (version 6.21.0 through 9.0.0)
- **PDK**: Puppet Development Kit (version 3.4.0) - Modern Puppet development toolchain
- **Ruby**: Implementation language for Puppet modules and tests
- **ZFS**: Target filesystem technology for backup operations
- **znapzend**: External ZFS backup daemon being managed

### Init Systems Supported
- **systemd**: RedHat/CentOS service management
- **rc.d**: FreeBSD startup system
- **SMF**: Solaris Service Management Facility

### Operating System Support
- RedHat/CentOS (versions 7, 8, 9)
- FreeBSD (versions 12, 13, 14)
- Solaris (version 11)

## Modern Development Dependencies

### Ruby Gems ([`Gemfile`](Gemfile:1)) - PDK-Managed
- **puppet**: Dynamic version via environment variables (supports 6.21.0-9.0.0)
- **facter**: Dynamic version via environment variables
- **hiera**: Dynamic version via environment variables
- **puppetlabs_spec_helper**: `~> 8.0` (modern testing helpers)
- **rspec-puppet-facts**: `~> 4.0` (Puppet-specific RSpec extensions)

### Testing & Quality Tools (Modern Stack)
- **voxpupuli-puppet-lint-plugins**: `~> 5.0` (comprehensive lint plugin collection)
- **metadata-json-lint**: `~> 4.0` (metadata validation)
- **dependency_checker**: `~> 1.0.0` (dependency analysis)
- **rubocop**: `~> 1.50.0` (Ruby style enforcement)
- **rubocop-performance**: `= 1.16.0` (performance linting)
- **rubocop-rspec**: `= 2.19.0` (RSpec-specific linting)
- **simplecov-console**: `~> 0.9` (test coverage reporting)

### Build & CI Tools (PDK-Integrated)
- **puppet-strings**: `~> 4.0` (automated documentation)
- **puppet-blacksmith**: `~> 7.0` (Puppet Forge publishing)
- **puppet_litmus**: `~> 1.0` (acceptance testing framework)
- **parallel_tests**: `= 3.12.1` (parallel test execution)

### Development & Debugging Tools
- **puppet-debugger**: `~> 1.0` (interactive Puppet debugging)
- **pry**: `~> 0.10` (Ruby REPL and debugger)
- **facterdb**: `~> 2.1` (fact database for testing)

## External Dependencies

### Puppet Module Dependencies ([`metadata.json`](metadata.json:10))
- **puppetlabs-stdlib**: `>= 6.0.0 < 10.0.0` (modern standard library)

### Fixture Dependencies ([`.fixtures.yml`](.fixtures.yml:4))
- **puppetlabs-stdlib**: Fixed at version `9.4.0` for testing consistency

### System Requirements
- **ZFS**: Must be available on target systems
- **SSH**: For remote backup destinations (passwordless auth required)
- **mbuffer**: Optional performance enhancement tool
- **sudo**: Required for ZFS privilege escalation

## PDK-Based Development Workflow

### Project Structure (PDK Standard)
```
puppet-znapzend/
├── data/              # Hiera data files (v5)
├── manifests/         # Puppet module classes and defines
├── templates/         # ERB and EPP configuration templates
├── spec/              # RSpec test suite
├── .github/workflows/ # GitHub Actions CI/CD
├── metadata.json      # PDK-managed module metadata
├── pdk.yaml          # PDK configuration
├── hiera.yaml        # Hiera v5 configuration
├── Gemfile           # Ruby dependencies (PDK-managed)
└── Rakefile          # Build automation (PDK-generated)
```

### Modern Template Architecture
**Dual Format Support for Compatibility:**
- **ERB Templates**: Traditional format for backward compatibility
- **EPP Templates**: Modern type-safe format with parameter validation

### Testing Framework ([`spec/spec_helper.rb`](spec/spec_helper.rb:1))
- **RSpec**: Modern testing framework
- **puppetlabs_spec_helper**: PDK-integrated testing utilities
- **Cross-platform testing**: Automated testing across supported OS versions
- **Fact-driven testing**: Uses facterdb for consistent test environments

### Build Configuration (PDK-Generated)
- **Automated linting**: Multiple lint plugins with modern standards
- **Type checking**: EPP template parameter validation
- **Dependency validation**: Automated dependency checking
- **Documentation**: Puppet Strings integration for automated docs

## Hiera v5 Data Architecture

### Configuration ([`hiera.yaml`](hiera.yaml:1))
- **Version**: Hiera v5 (modern data layer)
- **Backend**: YAML data backend
- **Hierarchy**: OS-specific parameter resolution with fallbacks

### Data Organization ([`data/`](data/))
- **Common defaults**: [`data/common.yaml`](data/common.yaml:1)
- **OS-specific overrides**: [`data/os/{OS}.yaml`](data/os/) files
- **Hierarchical lookups**: Major version and kernel release support

## Platform-Specific Paths & Binaries (Hiera-Driven)

### File System Paths (from [`data/common.yaml`](data/common.yaml:23) + OS overrides)
- **mbuffer**:
  - Solaris: `/opt/csw/bin` ([`data/os/Solaris.yaml`](data/os/Solaris.yaml:3))
  - FreeBSD: `/usr/local/bin` ([`data/os/FreeBSD.yaml`](data/os/FreeBSD.yaml:3))
  - Default: `/usr/bin`

- **sudo.d**:
  - FreeBSD: `/usr/local/etc/sudoers.d`
  - Solaris: `/etc/opt/csw/sudoers.d`
  - Default: `/etc/sudoers.d`

- **ZFS binaries**:
  - RedHat: `/usr/sbin` ([`data/os/RedHat.yaml`](data/os/RedHat.yaml:4))
  - Default: `/sbin`

### Service Management Commands (Hiera Data)
- **RedHat**: `systemctl reload znapzend`
- **Solaris**: `svcadm refresh znapzend`
- **Default**: `service znapzend reload`

## Configuration Templates

### ERB Templates (Legacy Compatibility)
- **Template engine**: ERB (Embedded Ruby)
- **Variable access**: Uses instance variables (`@variable`)
- **OS-specific templates**: Separate templates for each init system

### EPP Templates (Modern Type-Safe)
- **Template engine**: EPP (Embedded Puppet)
- **Parameter definitions**: Strong typing with Puppet data types
- **Compile-time validation**: Type checking during catalog compilation
- **Example type signature**:
```epp
<%- | String[1] $user,
      Stdlib::Absolutepath $zfs_path,
      Stdlib::Absolutepath $mbuffer_path,
| -%>
```

### Key Templates (Dual Format)
1. **[`znapzend.conf.erb`](templates/znapzend.conf.erb:1)/[`.epp`](templates/znapzend.conf.epp:1)**: Backup plan configuration
2. **[`znapzend_sudo.erb`](templates/znapzend_sudo.erb:1)/[`.epp`](templates/znapzend_sudo.epp:1)**: Type-safe sudo privileges
3. **Init scripts**: Platform-specific service management (dual formats)

## CI/CD & Automation

### GitHub Actions ([`.github/workflows/`](.github/workflows/))
- **[`release.yml`](.github/workflows/release.yml:1)**: Automated releases and Puppet Forge publishing
- **Ruby 3.2**: Modern Ruby environment
- **Automated testing**: Full test suite execution on releases
- **Forge deployment**: Automated publishing to Puppet Forge

### Dependency Management
- **[`renovate.json`](renovate.json:1)**: Automated dependency updates
- **PDK maintenance**: Automated PDK template updates
- **Security scanning**: Automated vulnerability detection

## Development Environment Setup

### PDK-Based Setup
```bash
# Install PDK (replaces manual gem management)
# PDK provides unified development experience

# Initialize development environment
pdk bundle install

# Validate module structure and syntax
pdk validate

# Run comprehensive test suite
pdk test unit

# Build module package
pdk build
```

### Modern Development Workflow
- **PDK commands**: Standardized development commands
- **Automated validation**: Syntax, lint, and type checking
- **Integrated testing**: Unit and acceptance testing
- **Template generation**: PDK-generated boilerplate code

### Code Quality Standards
- **Modern linting**: Comprehensive rule sets with contemporary standards
- **Type safety**: EPP template parameter validation
- **Ruby standards**: RuboCop integration with performance and RSpec plugins
- **Dependency checking**: Automated dependency conflict detection

## External Tool Integration

### znapzend Integration
- **Installation path**: `/opt/znapzend/bin` (configurable via Hiera)
- **Configuration tool**: `znapzendzetup import --write`
- **Service features**: Support for `oracleMode`, `recvu`, `pfexec`, `sudo`

### Security Model
- Non-root execution with dedicated user account
- Type-safe sudo privileges through EPP templates
- Hiera-driven security configuration
- Secure file permissions and ownership

## Version Compatibility

### Puppet Version Support
- **Minimum**: Puppet 6.21.0
- **Maximum**: Puppet 9.0.0 (not inclusive)
- **Recommended**: Puppet 7.x or 8.x for modern features

### Ruby Compatibility
- **Ruby 2.7+**: JSON gem compatibility handling
- **Ruby 3.x**: Full support with modern gem versions
- **Platform-specific**: Windows compatibility for development tools