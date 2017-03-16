require 'spec_helper'

describe 'znapzend', :type => :class do

  ['CentOS', 'FreeBSD'].each do |system|
    context "when on system #{system}" do
      if system == 'CentOS'
        let(:facts) do
          {
            :osfamily        => 'RedHat',
            :operatingsystem => system,
          }
        end
      else
        let(:facts) do
          {
            :osfamily        => system,
            :operatingsystem => system,
          }
        end
      end

    it { should contain_class('znapzend::install') }
    it { should contain_class('znapzend::service') }
    it { should contain_class('znapzend::plans') }

    describe 'znapzend::install' do
      let(:params) {{
        :package_ensure => 'present',
        :package_name   => 'znapzend',
        :package_manage => true,
      }}
      it { should contain_package('znapzend').with_ensure('present') }

      describe 'should allow package ensure to be overridden' do
        let(:params) {{
          :package_ensure => 'latest',
          :package_name   => 'znapzend',
        }}
        it { should contain_package('znapzend').with_ensure('latest') }
      end

      describe 'should allow the package name to be overridden' do
        let(:params) {{
          :package_name => 'foo',
        }}
        it { should contain_package('foo') }
      end

      describe 'should allow the package to be unmanaged' do
        let(:params) {{
          :package_name   => 'intermapper',
          :package_manage => false,
        }}
        it { should_not contain_package('intermapper') }
      end
    end # describe znapzend::install

    describe 'znapzend::service' do

      let(:params) {{
        :service_name => 'znapzend',
      }}      
      describe 'with defaults' do
        it { should contain_service('znapzend').with({
          :hasstatus => true,
          :ensure    => 'running',
          :enable    => true,
        })}
      end

      
    end # describe znapzend::service

    end
  end
end
