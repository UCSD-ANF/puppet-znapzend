require 'spec_helper' # frozen_string_literal: true

# rubocop:disable Metrics/BlockLength
describe 'znapzend::plan', type: 'define' do
  let :title do
    'tank/foo'
  end

  shared_context 'Supported Platform' do
    it do should compile.with_all_deps end
    it do is_expected.to contain_class('znapzend') end
    it do
      is_expected.to contain_exec('load_tank_foo').with(
        refreshonly: true
      ).that_subscribes_to('Class[znapzend::service]')
    end
    it do
      is_expected.to contain_file(
        '/usr/local/etc/znapzend/tank_foo'
      ).with_content(
        "enabled=on\n" +
        "mbuffer=off\n" +
        "mbuffer_size=1G\n" +
        "post_znap_cmd=off\n" +
        "pre_znap_cmd=off\n" +
        "recursive=on\n" +
        "src=tank/foo\n" +
        "src_plan=1day=>1hour,1mon=>1day\n" +
        "tsformat=%Y-%m-%d-%H%M%S\n" +
        "zend_delay=0\n"
      ).that_notifies('Exec[load_tank_foo]')
    end
  end

  shared_context 'FreeBSD' do
    it do
      is_expected.to contain_exec(
        'load_tank_foo'
      ).with(
        command: '/usr/local/bin/znapzendzetup import --write tank/foo ' +
                 '< /usr/local/etc/znapzend/tank_foo; ' +
                 '/usr/sbin/service znapzend reload'
      )
    end
  end

  shared_context 'RedHat' do
    it do
      is_expected.to contain_exec(
        'load_tank_foo'
      ).with(
        command: '/opt/znapzend/bin/znapzendzetup import --write tank/foo ' +
                 '< /usr/local/etc/znapzend/tank_foo; ' +
                 '/bin/systemctl reload znapzend'
      )
    end
  end

  shared_context 'Solaris' do
    it do
      is_expected.to contain_exec(
        'load_tank_foo'
      ).with(
        command: '/opt/znapzend/bin/znapzendzetup import --write tank/foo ' +
                 '< /usr/local/etc/znapzend/tank_foo; svcadm refresh znapzend'
      )
    end
  end

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let :facts do
        facts
      end

      case facts[:os]['family']
      when 'FreeBSD' then
        include_context 'Supported Platform'
        it_behaves_like 'FreeBSD'
      when 'RedHat' then
        include_context 'Supported Platform'
        it_behaves_like 'RedHat'
      when 'Solaris' then
        include_context 'Supported Platform'
        it_behaves_like 'Solaris'
      end
    end
  end

end
# rubocop:enable Metrics/BlockLength
