source 'https://rubygems.org'

### Environment variable version overrrides

# facter
# puppet
puppet_version = ENV.key?('PUPPET_VERSION') ? "= #{ENV['PUPPET_VERSION']}" : \
  '= 5.5.10' # from puppet enterprise 2016.4

### Gem requirements
gem 'json_pure'
gem 'rake'
gem 'rspec'
gem 'facter'
gem 'metadata-json-lint'
gem 'puppet', puppet_version
gem 'rspec-puppet', '>= 2.0'
gem 'rspec-puppet-facts'
gem 'puppet-lint', :require => false
gem 'puppet-syntax', :require => false

gem 'puppet-lint'
# http://www.camptocamp.com/en/actualite/getting-code-ready-puppet-4/
gem 'puppet-lint-unquoted_string-check'
gem 'puppet-lint-empty_string-check'
gem 'puppet-lint-leading_zero-check'
gem 'puppet-lint-variable_contains_upcase'
gem 'puppet-lint-spaceship_operator_without_tag-check'
#gem 'puppet-lint-absolute_classname-check'
#gem 'puppet-lint-undef_in_function-check'
gem 'puppet-lint-roles_and_profiles-check'

gem 'puppetlabs_spec_helper'
gem 'git', '>= 1.2.6'
gem 'ci_reporter_rspec'
gem 'parallel_tests', :require => false
