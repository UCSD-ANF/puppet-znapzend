require 'spec_helper'

describe 'znapzend', :type => :class do

  ['CentOS', 'RedHat', 'FreeBSD', 'Solaris'].each do |system|
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
      if system == "Solaris"
        let(:params) {{
          :package_manage => false,
          :package_name   => 'znapzend',
        }}
        it { should_not contain_package('znapzend') }
      else
        let(:params) {{
          :package_ensure => 'present',
          :package_name   => 'znapzend',
          :package_manage => true,
        }}
        it { should contain_package('znapzend').with_ensure('present') }

        context 'should allow package ensure to be overridden' do
          let(:params) {{
            :package_ensure => 'latest',
            :package_name   => 'znapzend',
          }}
          it { should contain_package('znapzend').with_ensure('latest') }
        end

        context 'should allow the package name to be overridden' do
          let(:params) {{
            :package_name => 'foo',
          }}
          it { should contain_package('foo') }
        end

        context 'should allow the package to be unmanaged' do
          let(:params) {{
            :package_name   => 'znapzend',
            :package_manage => false,
          }}
          it { should_not contain_package('znapzend') }
        end

      end
 
      describe 'init.d script' do

        let(:params) {{
          :service_name => 'znapzend',
        }}      

        if system == "FreeBSD"
          context 'should create init.d script on FreeBSD' do
            it { should contain_file('/usr/local/etc/rc.d/znapzend') }
          end
        end
   
        if system == "RedHat"
          context 'should create init.d script on RedHat osFamily' do
            it { should contain_file('/lib/systemd/system/znapzend.service') }
          end
        end
   
        if system == "Solaris"
          context 'should create init.d script on Solaris' do
            it { should contain_file('/lib/svc/method/znapzend') }
            it { should contain_file('/var/svc/manifest/system/filesystem/znapzend.xml') }
          end
        end
   
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

    # test multiple plans can be passed
    describe 'znapzend::plans' do 
      let :params do {
        :plans => {
          'tank_foobar' => {
            'config_file'     => 'tank_foobar',
          },
          'backup_tank' => {
            'config_file'     => 'backup_tank',
          },
        },
      }
      end
      it { should contain_znapzend__config('tank_foobar') }
      it { should contain_znapzend__config('backup_tank') }

    end # end znapzend::plans

    end
  end
end
