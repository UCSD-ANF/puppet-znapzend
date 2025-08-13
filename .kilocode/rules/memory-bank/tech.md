# Technologies & Development Setup: puppet-znapzend

## Core Technologies

### Primary Technologies
- **Puppet**: Configuration management framework (version 3.8.5 from PE 3.8.0)
- **Ruby**: Implementation language for Puppet modules and tests
- **ZFS**: Target filesystem technology for backup operations
- **znapzend**: External ZFS backup daemon being managed

### Init Systems Supported
- **systemd**: RedHat/CentOS service management
- **rc.d**: FreeBSD startup system
- **SMF**: Solaris Service Management Facility

### Operating System Support
- RedHat/CentOS (osfamily: RedHat)
- FreeBSD (osfamily: FreeBSD)
- Solaris (osfamily: Solaris)

## Development Dependencies

### Ruby Gems ([`Gemfile`](Gemfile:1))
- **puppet**: `= 3.8.5` (from Puppet Enterprise 3.8.0)
- **facter**: `= 2.4.4` (from Puppet Enterprise 3.8.5)
- **hiera**: `= 1.3.4` (from Puppet Enterprise 3.8.0)
- **rspec**: `< 3.0.0` (testing framework)
- **rspec-puppet**: `>= 2.0` (Puppet-specific RSpec extensions)

### Testing & Quality Tools
- **puppet-syntax**: Syntax validation
- **puppet-lint**: Code style enforcement with plugins:
  - `puppet-lint-unquoted_string-check`
  - `puppet-lint-empty_string-check`
  - `puppet-lint-leading_zero-check`
  - `puppet-lint-variable_contains_upcase`
  - `puppet-lint-spaceship_operator_without_tag-check`
  - `puppet-lint-roles_and_profiles-check`

### Build & CI Tools
- **rake**: `< 11` (task automation)
- **puppetlabs_spec_helper**: Testing helpers
- **ci_reporter_rspec**: CI reporting
- **parallel_tests**: `< 2.10.0` (parallel test execution)

## External Dependencies

### Puppet Module Dependencies ([`.fixtures.yml`](./fixtures.yml:2))
- **puppetlabs-stdlib**: Standard library functions
- **puppet-staging**: File staging utilities

### System Requirements
- **ZFS**: Must be available on target systems
- **SSH**: For remote backup destinations (passwordless auth required)
- **mbuffer**: Optional performance enhancement tool
- **sudo**: Required for ZFS privilege escalation

## Development Workflow

### Project Structure
```
puppet-znapzend/
├── manifests/          # Puppet module classes and defines
├── templates/          # ERB configuration templates
├── spec/              # RSpec test suite
├── Gemfile            # Ruby dependencies
├── Rakefile           # Build automation
└── .fixtures.yml      # Test fixtures and dependencies
```

### Testing Framework ([`spec/spec_helper.rb`](spec/spec_helper.rb:1))
- **RSpec**: Primary testing framework
- **puppetlabs_spec_helper**: Provides Puppet testing utilities
- **Cross-platform testing**: Tests run against CentOS, RedHat, FreeBSD, Solaris

### Build Configuration ([`Rakefile`](Rakefile:1))
- **puppet-lint**: Automated code quality checks
- **Relative paths**: Enabled for lint checking
- **Documentation**: Disabled (line 6)
- **Ignore paths**: `spec/**/*.pp`, `pkg/**/*.pp`

## Platform-Specific Paths & Binaries

### File System Paths (from [`params.pp`](manifests/params.pp:24))
- **mbuffer**:
  - Solaris: `/opt/csw/bin`
  - FreeBSD: `/usr/local/bin` 
  - Default: `/usr/bin`

- **sudo.d**:
  - FreeBSD: `/usr/local/etc/sudoers.d`
  - Solaris: `/etc/opt/csw/sudoers.d`
  - Default: `/etc/sudoers.d`

- **ZFS binaries**:
  - RedHat: `/usr/sbin`
  - Default: `/sbin`

- **User shell**:
  - FreeBSD: `/usr/local/bin/bash`
  - Default: `/bin/bash`

### Service Management Commands
- **RedHat**: `systemctl reload znapzend`
- **Solaris**: `svcadm refresh znapzend`
- **Default**: `service znapzend reload`

## Configuration Templates

### ERB Template System
- **Template engine**: ERB (Embedded Ruby)
- **Variable access**: Uses `scope.lookupvar()` for Puppet variables
- **OS-specific templates**: Separate templates for each init system

### Key Templates
1. **[`znapzend.conf.erb`](templates/znapzend.conf.erb:1)**: Backup plan configuration
2. **[`znapzend_sudo.erb`](templates/znapzend_sudo.erb:1)**: Sudo privileges
3. **Init scripts**: Platform-specific service management

## Development Environment Setup

### Initial Setup
```bash
# Install Ruby dependencies
bundle install

# Run syntax and lint checks
rake syntax
rake lint

# Run full test suite
rake spec
```

### Test Execution Pattern
- Tests iterate over supported OS families: `['CentOS', 'RedHat', 'FreeBSD', 'Solaris']`
- Each OS context tests installation, service management, and configuration
- Validates OS-specific file creation and package management

### Code Quality Standards
- Lint configuration enforces Puppet best practices
- Documentation requirements disabled for this module
- Relative path checking enabled
- Multiple specialized lint plugins for code quality

## External Tool Integration

### znapzend Integration
- **Installation path**: `/opt/znapzend/bin` (configurable)
- **Configuration tool**: `znapzendzetup import --write`
- **Service features**: Support for `oracleMode`, `recvu`, `pfexec`, `sudo`

### Security Model
- Non-root execution with dedicated user account
- Minimal sudo privileges for ZFS commands only
- Secure file permissions and ownership