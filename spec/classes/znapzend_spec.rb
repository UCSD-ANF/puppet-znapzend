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
            :package_name   => 'znoobar',
          }}
          it { should contain_package('znoobar').with_ensure('latest') }
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
   
      describe 'manage sudo' do
        context 'should create znapzend sudo file' do
           let(:params) {{
             :sudo_d_path   => '/usr/local/etc/sudoers.d',
             :manage_sudo   => true,
           }}
           it { should contain_file('/usr/local/etc/sudoers.d/znapzend') }
        end  

        context 'should all for sudo to be unmanaged' do
           let(:params) {{
             :sudo_d_path   => '/usr/local/etc/sudoers.d',
             :manage_sudo   => false,
           }}
           it { should_not contain_file('/usr/local/etc/sudoers.d/znapzend') }
        end  
      end

      describe 'should create user and group' do
         let(:params) {{
           :manage_user      => true,
           :user             => 'znapzend',
           :group            => 'znapzend',
           :user_shell       => '/bin/bash',
           :user_home        => '/home/znapzend', 
           :service_pid_dir  => '/var/run/znapzend',
           :service_log_dir  => '/var/log/znapzend',
           :service_conf_dir => '/usr/local/etc/znapzend',
         }}

         it { should contain_group('znapzend').with({
           'ensure'  => 'present',
         })}
         it { should contain_user('znapzend').with({
           'ensure'  => 'present',
           'shell'    => '/bin/bash',
           'home'     => '/home/znapzend', 
         })}

         context 'should create pid dir' do
           it { should contain_file('/var/run/znapzend').with({
             'ensure' 	 => 'directory',
             'owner'     => 'znapzend',
             'group'     => 'znapzend',
             'mode'      => '0644',
             'recurse'   => true,
           })}
         end

         context 'should create log dir' do
           it { should contain_file('/var/log/znapzend').with({
             'ensure' 	 => 'directory',
             'owner'     => 'znapzend',
             'group'     => 'znapzend',
             'mode'      => '0755',
           })}
         end

         context 'should create config dir' do
           it { should contain_file('/usr/local/etc/znapzend').with({
             'ensure' 	 => 'directory',
             'owner'     => 'znapzend',
             'group'     => 'znapzend',
             'mode'      => '0755',
           })}
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
        :service_conf_dir => '/usr/local/etc/znapzend',
        :plans => {
          'tank_foobar' => {
            'config_src'     => 'tank/foobar',
          },
          'backup_tank' => {
            'config_src'     => 'backup/tank',
          },
        },
      }
      end
      it { should contain_file('/usr/local/etc/znapzend/tank_foobar').with({
        :owner  => "znapzend",
        :group  => "znapzend",
        :notify => "Exec[load_tank_foobar]",
      })}
      it { should contain_file('/usr/local/etc/znapzend/backup_tank').with({
        :owner  => "znapzend",
        :group  => "znapzend",
        :notify => "Exec[load_backup_tank]",
      })}

    end # end znapzend::plans

    end
  end
end
