# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [2.0.0] - 2025-08-13

### Breaking Changes

- **Minimum Puppet version:** Now requires Puppet 6.21.0 or higher (previously supported 3.8.5)
- **stdlib dependency:** Now requires puppetlabs/stdlib >= 6.0.0 < 10.0.0 (previously any version)
- **Template format:** All ERB templates converted to EPP format with breaking template syntax changes
- **Parameter validation:** Strict data type validation now enforced at compile time - invalid parameters will fail catalog compilation
- **Removed legacy compatibility:** Puppet 3.x compatibility code and workarounds have been removed

### Added

- **PDK Support:** Module now built using Puppet Development Kit (PDK) 3.4.0
- **Modern Data Types:** All parameters now use modern Puppet data types (Stdlib::Absolutepath, Boolean, Enum, etc.)
- **EPP Templates:** All templates converted from ERB to EPP format for better performance and type safety
- **Enhanced Validation:** Comprehensive compile-time parameter validation with descriptive error messages
- **Modern Testing:** Updated RSpec tests with modern patterns and PDK compatibility
- **Cross-Platform Support:** Enhanced support for CentOS/RHEL 7-9, FreeBSD 12-14, Solaris 11
- **PDK Development Workflow:** Full PDK integration with `pdk validate`, `pdk test unit`, and `pdk convert` support

### Changed

- **Module Structure:** Reorganized to follow PDK best practices and modern Puppet module standards
- **Parameter Types:** All class and define parameters now use strict Puppet 4+ data types
- **Template Variables:** EPP templates use modern `$variable` syntax instead of `scope.lookupvar()`
- **Error Messages:** Improved error messages with better context and troubleshooting information
- **Test Framework:** Updated test suite to use modern RSpec patterns and PDK testing standards
- **Documentation:** Completely rewritten README with modern usage examples and PDK workflow

### Fixed

- **Type Safety:** All parameter access is now type-safe with compile-time validation
- **Template Performance:** EPP templates provide better performance than legacy ERB templates
- **Cross-Platform Consistency:** Improved handling of OS-specific paths and service management
- **Service Management:** Enhanced service reload and status checking across all supported platforms

### Deprecated

- **ERB Templates:** Legacy ERB templates are retained for compatibility but EPP templates are preferred
- **Legacy Parameter Access:** Old-style parameter access patterns in custom templates

### Migration Guide

**Required Actions for Upgrading from 1.x:**

1. **Upgrade Dependencies:**
   ```bash
   # Ensure Puppet 6.21.0 or higher
   puppet --version
   
   # Update stdlib module
   puppet module upgrade puppetlabs-stdlib
   ```

2. **Test Your Configuration:**
   ```bash
   # Validate your Puppet code
   puppet parser validate manifests/site.pp
   
   # Test compilation
   puppet catalog compile --environment production
   ```

3. **Update Custom Templates (if any):**
   - Convert any custom ERB overrides to EPP format
   - Update variable access from `<%= scope.lookupvar('variable') %>` to `<%= $variable %>`

4. **Validate Parameters:**
   - Review any dynamic parameter generation to ensure type compatibility
   - Test with `--strict_variables` to catch undefined variables

**Most configurations will work without changes** - the module maintains API compatibility for all standard use cases.

### Development Changes

- **PDK Workflow:** Use `pdk validate` and `pdk test unit` for development
- **Modern Ruby:** Updated to support Ruby 2.5+ (dropped Ruby 1.9 support)  
- **Enhanced Testing:** Comprehensive test coverage with modern RSpec patterns
- **Code Quality:** Strict rubocop and puppet-lint compliance
- **CI/CD Ready:** Full GitHub Actions compatibility and automated testing

### Technical Details

**Template Conversion:**
- `znapzend.conf.erb` → `znapzend.conf.epp`
- `znapzend_sudo.erb` → `znapzend_sudo.epp` 
- `znapzend_init_centos.erb` → `znapzend_init_centos.epp`
- `znapzend_init_freebsd.erb` → `znapzend_init_freebsd.epp`
- `znapzend_init_solaris.erb` → `znapzend_init_solaris.epp`
- `znapzend.xml.erb` → `znapzend.xml.epp`

**Data Type Migration:**
- String parameters → `String[1]` (non-empty strings)
- Path parameters → `Stdlib::Absolutepath`
- Boolean parameters → `Boolean` 
- Service states → `Stdlib::Ensure::Service`
- Package states → `Enum['absent','latest','present']`

### Credits

- **Modernization Lead:** Geoff Davis - Complete PDK migration and modernization
- **Template Conversion:** Automated conversion from ERB to EPP templates
- **Testing Updates:** Modern RSpec test suite implementation
- **Documentation:** Comprehensive README and development guide updates

---

## [1.0.0] - 2019-XX-XX

### Features

- Initial release with Puppet 3.8.5 support
- Cross-platform support for CentOS, FreeBSD, and Solaris
- Comprehensive znapzend service management
- Flexible backup plan configuration
- User and sudo management for ZFS operations
- ERB template-based configuration system

### Bugfixes

- Various fixes during initial development

### Known Issues

- Limited to Puppet 3.x/4.x compatibility
- ERB template performance limitations
- Manual parameter validation

---

## Release Notes Format

**This changelog follows [Keep a Changelog](https://keepachangelog.com/en/1.0.0/) format:**

- **Added** for new features
- **Changed** for changes in existing functionality  
- **Deprecated** for soon-to-be removed features
- **Removed** for now removed features
- **Fixed** for any bug fixes
- **Security** for vulnerability fixes

**Version numbering follows [Semantic Versioning](https://semver.org/):**
- **MAJOR** version for incompatible API changes
- **MINOR** version for backwards-compatible functionality additions  
- **PATCH** version for backwards-compatible bug fixes
