# 🎉 puppet-znapzend v2.0.0 - Major Modernization Release

This is a **major release** with significant modernization and breaking changes. The module has been completely updated for modern Puppet workflows with PDK integration and enhanced cross-platform support.

## 🚨 Breaking Changes

- **Minimum Puppet version:** Now requires **Puppet 6.21.0+** (previously 3.8.5)
- **stdlib dependency:** Now requires **puppetlabs/stdlib >= 6.0.0 < 10.0.0**
- **Template format:** All ERB templates converted to EPP format
- **Parameter validation:** Strict data type validation enforced at compile time
- **Removed legacy:** Puppet 3.x compatibility code removed

## ✨ New Features & Improvements

### 🔧 Modern Development Stack
- **PDK Support:** Full Puppet Development Kit integration
- **Enhanced Validation:** Comprehensive compile-time parameter validation
- **Modern Data Types:** All parameters use Puppet 4+ data types (`Stdlib::Absolutepath`, `Boolean`, etc.)
- **GitHub Actions:** Complete CI/CD workflow with automated testing

### 🎯 Enhanced Cross-Platform Support
- **CentOS/RHEL:** 7, 8, 9
- **FreeBSD:** 12, 13, 14  
- **Solaris:** 11

### ⚡ Performance & Reliability
- **EPP Templates:** Better performance than legacy ERB templates
- **Type Safety:** Compile-time validation prevents runtime errors
- **Enhanced Error Messages:** Better troubleshooting information

## 🔄 Migration Guide

### Quick Start - Most configurations work without changes!

1. **Update Dependencies:**
   ```bash
   # Ensure Puppet 6.21.0+
   puppet --version
   
   # Update stdlib
   puppet module upgrade puppetlabs-stdlib
   ```

2. **Test Configuration:**
   ```bash
   # Validate Puppet code
   puppet parser validate manifests/site.pp
   
   # Test compilation
   puppet catalog compile --environment production
   ```

3. **Custom Templates (if any):**
   - Convert ERB overrides to EPP format
   - Update variable access: `<%= scope.lookupvar('var') %>` → `<%= $var %>`

### Template Migration Reference

| Legacy ERB | Modern EPP |
|------------|------------|
| `znapzend.conf.erb` | `znapzend.conf.epp` |
| `znapzend_sudo.erb` | `znapzend_sudo.epp` |
| `znapzend_init_centos.erb` | `znapzend_init_centos.epp` |
| `znapzend_init_freebsd.erb` | `znapzend_init_freebsd.epp` |
| `znapzend_init_solaris.erb` | `znapzend_init_solaris.epp` |
| `znapzend.xml.erb` | `znapzend.xml.epp` |

## 🛠️ Technical Details

**Data Type Upgrades:**
- String parameters → `String[1]` (non-empty)
- Path parameters → `Stdlib::Absolutepath`
- Boolean parameters → `Boolean`
- Service states → `Stdlib::Ensure::Service`
- Package states → `Enum['absent','latest','present']`

**Development Workflow:**
- Use `pdk validate` and `pdk test unit`
- Modern RSpec patterns with comprehensive coverage
- Strict rubocop and puppet-lint compliance

## 📚 Resources

- **Full Changelog:** See [CHANGELOG.md](CHANGELOG.md) for complete details
- **Issues:** Report problems on [GitHub Issues](https://github.com/IGPP/puppet-znapzend/issues)
- **Documentation:** Updated README with modern examples

## 🙏 Credits

- **Modernization Lead:** Geoff Davis - Complete PDK migration and modernization
- **Template Conversion:** Automated ERB → EPP migration
- **Testing Updates:** Modern RSpec test suite implementation
- **Documentation:** Comprehensive usage guides and examples

---

**Note:** This release maintains API compatibility for standard use cases. Advanced users with custom templates may need minor adjustments following the migration guide above.