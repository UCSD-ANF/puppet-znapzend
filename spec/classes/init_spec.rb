require 'spec_helper' # frozen_string_literal: true

# rubocop:disable Metrics/BlockLength
describe 'znapzend', type: :class do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let :facts do
        facts
      end

      it do
        should contain_class(
          'znapzend::install'
        ).that_comes_before('Class[znapzend::config]')
      end
      it do
        should contain_class(
          'znapzend::config'
        ).that_notifies('Class[znapzend::service]')
      end
      it do
        should contain_class(
          'znapzend::service'
        ).that_comes_before('Class[znapzend::plans]')
      end
      it do should contain_class('znapzend::plans') end

      describe 'znapzend::install' do
        if facts[:os]['family'] == 'Solaris'
          it do should_not contain_package('znapzend') end
        else
          let :params do
            {
              package_ensure: 'present',
              package_name: 'znapzend',
              package_manage: true
            }
          end
          it do should contain_package('znapzend').with_ensure('present') end

          context 'should allow package ensure to be overridden' do
            let :params do
              {
                package_ensure: 'latest',
                package_name: ['zfoo', 'zbar', 'zbaz'],
                package_manage: true
              }
            end
            it do should contain_package('zfoo').with_ensure('latest') end
            it do should contain_package('zbar').with_ensure('latest') end
            it do should contain_package('zbaz').with_ensure('latest') end
            it do should_not contain_package('znapzend') end
          end

          context 'should allow the package name to be overridden' do
            let :params do
              { package_name: 'foo', package_manage: true }
            end
            it do should contain_package('foo') end
          end

          context 'should allow the package to be unmanaged' do
            let :params do
              { package_name: 'znapzend', package_manage: false }
            end
            it do should_not contain_package('znapzend') end
          end
        end
      end

      describe 'znapzend::config' do
        describe 'init.d script' do
          let :params do
            { service_name: 'znapzend' }
          end

          case facts[:os][:family]
          when 'FreeBSD' then
            context 'should not create init.d script on FreeBSD' do
              it do
                should_not contain_file('/usr/local/etc/rc.d/znapzend')
              end
            end
            context 'should create init.d script on FreeBSD' do
              let :params do
                { manage_init: true }
              end
              it do
                should contain_file('/usr/local/etc/rc.d/znapzend').with(
                  ensure: 'file',
                  owner: 'root',
                  group: 'wheel',
                  mode: '0555',
                  content: %r{\ncommand="/usr/local/bin/znapzend"}
                )
              end
            end

          when 'RedHat' then
            context 'should create init.d script on RedHat osFamily' do
              it do
                should contain_file(
                  '/lib/systemd/system/znapzend.service'
                ).with(
                  ensure: 'file',
                  owner: 'root',
                  group: 'root',
                  mode: '0644',
                  content: %r{\nExecStart=/opt/znapzend/bin/znapzend}
                )
              end
            end
            context 'should not create init.d script on RedHat osFamily' do
              let :params do
                { manage_init: false }
              end
              it do
                should_not contain_file('/lib/systemd/system/znapzend.service')
              end
            end

          when 'Solaris' then
            context 'should create init.d script on Solaris' do
              it do should contain_file('/lib/svc/method/znapzend') end
              it do
                should contain_file(
                  '/var/svc/manifest/system/filesystem/znapzend.xml'
                )
              end
            end
            context 'should_not create init.d script on Solaris' do
              let :params do
                { manage_init: false }
              end
              it do should_not contain_file('/lib/svc/method/znapzend') end
              it do
                should_not contain_file(
                  '/var/svc/manifest/system/filesystem/znapzend.xml'
                )
              end
            end
          end
        end

        describe 'manage sudo' do
          context 'should create znapzend sudo file' do
            let :params do
              { sudo_d_path: '/usr/local/etc/sudoers.d', manage_sudo: true }
            end
            it do should contain_file('/usr/local/etc/sudoers.d/znapzend') end
          end

          context 'should all for sudo to be unmanaged' do
            let :params do
              { sudo_d_path: '/usr/local/etc/sudoers.d', manage_sudo: false }
            end
            it do
              should_not contain_file('/usr/local/etc/sudoers.d/znapzend')
            end
          end
        end

        describe 'should create user and group' do
          let :params do
            {
              manage_user: true,
              user: 'znapzend',
              group: 'znapzend',
              user_shell: '/bin/bash',
              user_home: '/home/znapzend',
              service_pid_dir: '/var/run/znapzend',
              service_log_dir: '/var/log/znapzend',
              service_conf_dir: '/usr/local/etc/znapzend'
            }
          end

          it do
            should contain_group(
              'znapzend'
            ).with_ensure('present').that_comes_before('User[znapzend]')
          end
          it do
            should contain_user('znapzend').with(
              ensure: 'present',
              shell: '/bin/bash',
              home: '/home/znapzend'
            )
          end

          context 'should create pid dir' do
            it do
              should contain_file('/var/run/znapzend').with(
                ensure: 'directory',
                owner: 'znapzend',
                group: 'znapzend',
                mode: '0755',
                recurse: nil
              )
            end
          end

          context 'should create log dir' do
            it do
              should contain_file('/var/log/znapzend').with(
                ensure: 'directory',
                owner: 'znapzend',
                group: 'znapzend',
                mode: '0755'
              )
            end
          end

          context 'should create config dir' do
            it do
              should contain_file('/usr/local/etc/znapzend').with(
                ensure: 'directory',
                owner: 'znapzend',
                group: 'znapzend',
                mode: '0755'
              )
            end
          end
        end
      end

      describe 'znapzend::service' do
        let :params do
          { service_name: 'znapzend' }
        end
        describe 'with defaults' do
          it do
            should contain_service('znapzend').with(
              hasstatus: true,
              ensure: 'running',
              enable: true
            )
          end
        end
      end

      # test multiple plans can be passed
      describe 'znapzend::plans' do
        let :params do
          {
            service_conf_dir: '/usr/local/etc/znapzend',
            plans: {
              'tank/foobar': {},
              backup_tank: { config_src: 'backup/tank' }
            }
          }
        end
        it do should contain_znapzend__plan('tank/foobar') end
        it do should contain_znapzend__plan('backup_tank') end
      end
    end
  end
end
# rubocop:enable Metrics/BlockLength
