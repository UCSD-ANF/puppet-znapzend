require 'spec_helper'

describe 'znapzend', type: :class do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      it { is_expected.to contain_class('znapzend::install') }
      it { is_expected.to contain_class('znapzend::service') }
      it { is_expected.to contain_class('znapzend::plans') }

      describe 'znapzend::install' do
        case os_facts[:os]['family']
        when 'Solaris'
          let(:params) do
            {
              package_manage: false,
              package_name: 'znapzend',
            }
          end
          it { is_expected.not_to contain_package('znapzend') }
        else
          let(:params) do
            {
              package_ensure: 'present',
              package_name: 'znapzend',
              package_manage: true,
            }
          end
          it { is_expected.to contain_package('znapzend').with_ensure('present') }

          context 'should allow package ensure to be overridden' do
            let(:params) do
              {
                package_ensure: 'latest',
                package_name: 'znoobar',
              }
            end

            it { is_expected.to contain_package('znoobar').with_ensure('latest') }
          end

          context 'should allow the package name to be overridden' do
            let(:params) do
              {
                package_name: 'foo',
              }
            end

            it { is_expected.to contain_package('foo') }
          end

          context 'should allow the package to be unmanaged' do
            let(:params) do
              {
                package_name: 'znapzend',
                package_manage: false,
              }
            end

            it { is_expected.not_to contain_package('znapzend') }
          end
        end

        describe 'init.d script' do
          let(:params) do
            {
              service_name: 'znapzend',
            }
          end

          case os_facts[:os]['family']
          when 'FreeBSD'
            context 'should create init.d script on FreeBSD' do
              it { is_expected.to contain_file('/usr/local/etc/rc.d/znapzend') }
            end
          when 'RedHat'
            context 'should create init.d script on RedHat osFamily' do
              it { is_expected.to contain_file('/lib/systemd/system/znapzend.service') }
            end
          when 'Solaris'
            context 'should create init.d script on Solaris' do
              it { is_expected.to contain_file('/lib/svc/method/znapzend') }
              it { is_expected.to contain_file('/var/svc/manifest/system/filesystem/znapzend.xml') }
            end
          end
        end

        describe 'manage sudo' do
          context 'should create znapzend sudo file' do
            let(:params) do
              {
                sudo_d_path: '/usr/local/etc/sudoers.d',
              manage_sudo: true,
              }
            end

            it { is_expected.to contain_file('/usr/local/etc/sudoers.d/znapzend') }
          end

          context 'should all for sudo to be unmanaged' do
            let(:params) do
              {
                sudo_d_path: '/usr/local/etc/sudoers.d',
              manage_sudo: false,
              }
            end

            it { is_expected.not_to contain_file('/usr/local/etc/sudoers.d/znapzend') }
          end
        end

        describe 'should create user and group' do
          let(:params) do
            {
              manage_user: true,
            user: 'znapzend',
            group: 'znapzend',
            user_shell: '/bin/bash',
            user_home: '/home/znapzend',
            service_pid_dir: '/var/run/znapzend',
            service_log_dir: '/var/log/znapzend',
            service_conf_dir: '/usr/local/etc/znapzend',
            }
          end

          it {
            is_expected.to contain_group('znapzend').with({
                                                            'ensure' => 'present',
                                                          })
          }
          it {
            is_expected.to contain_user('znapzend').with({
                                                           'ensure' => 'present',
               'shell'    => '/bin/bash',
               'home'     => '/home/znapzend',
                                                         })
          }

          context 'should create pid dir' do
            it {
              is_expected.to contain_file('/var/run/znapzend').with({
                                                                      'ensure' 	 => 'directory',
                 'owner'     => 'znapzend',
                 'group'     => 'znapzend',
                 'mode'      => '0644',
                 'recurse'   => true,
                                                                    })
            }
          end

          context 'should create log dir' do
            it {
              is_expected.to contain_file('/var/log/znapzend').with({
                                                                      'ensure' 	 => 'directory',
                 'owner'     => 'znapzend',
                 'group'     => 'znapzend',
                 'mode'      => '0755',
                                                                    })
            }
          end

          context 'should create config dir' do
            it {
              is_expected.to contain_file('/usr/local/etc/znapzend').with({
                                                                            'ensure' 	 => 'directory',
                 'owner'     => 'znapzend',
                 'group'     => 'znapzend',
                 'mode'      => '0755',
                                                                          })
            }
          end
        end
      end # describe znapzend::install

      describe 'znapzend::service' do
        let(:params) do
          {
            service_name: 'znapzend',
          }
        end

        describe 'with defaults' do
          it {
            is_expected.to contain_service('znapzend').with({
                                                              hasstatus: true,
              ensure: 'running',
              enable: true,
                                                            })
          }
        end
      end # describe znapzend::service

      # test multiple plans can be passed
      describe 'znapzend::plans' do
        let :params do
          {
            service_conf_dir: '/usr/local/etc/znapzend',
            plans: {
              'tank_foobar' => {
                'config_src'     => 'tank/foobar',
              },
              'backup_tank' => {
                'config_src'     => 'backup/tank',
              },
            },
          }
        end

        it {
          is_expected.to contain_file('/usr/local/etc/znapzend/tank_foobar').with({
                                                                                    owner: 'znapzend',
            group: 'znapzend',
            notify: 'Exec[load_tank_foobar]',
                                                                                  })
        }
        it {
          is_expected.to contain_file('/usr/local/etc/znapzend/backup_tank').with({
                                                                                    owner: 'znapzend',
            group: 'znapzend',
            notify: 'Exec[load_backup_tank]',
                                                                                  })
        }
      end # end znapzend::plans

      # Test data type validation for modernized parameters
      describe 'parameter validation' do
        context 'with invalid package_ensure value' do
          let(:params) { { package_ensure: 'invalid' } }

          it { is_expected.to compile.and_raise_error(%r{expects a match for Enum}) }
        end

        context 'with invalid boolean for manage_user' do
          let(:params) { { manage_user: 'not_a_boolean' } }

          it { is_expected.to compile.and_raise_error(%r{expects a Boolean}) }
        end

        context 'with invalid boolean for manage_sudo' do
          let(:params) { { manage_sudo: 'not_a_boolean' } }

          it { is_expected.to compile.and_raise_error(%r{expects a Boolean}) }
        end

        context 'with invalid boolean for package_manage' do
          let(:params) { { package_manage: 'not_a_boolean' } }

          it { is_expected.to compile.and_raise_error(%r{expects a Boolean}) }
        end

        context 'with invalid boolean for service_enable' do
          let(:params) { { service_enable: 'not_a_boolean' } }

          it { is_expected.to compile.and_raise_error(%r{expects a Boolean}) }
        end

        context 'with invalid boolean for service_hasstatus' do
          let(:params) { { service_hasstatus: 'not_a_boolean' } }

          it { is_expected.to compile.and_raise_error(%r{expects a Boolean}) }
        end

        context 'with empty string for user' do
          let(:params) { { user: '' } }

          it { is_expected.to compile.and_raise_error(%r{expects a String\[1\]}) }
        end

        context 'with empty string for group' do
          let(:params) { { group: '' } }

          it { is_expected.to compile.and_raise_error(%r{expects a String\[1\]}) }
        end

        context 'with empty string for package_name' do
          let(:params) { { package_name: '' } }

          it { is_expected.to compile.and_raise_error(%r{expects a String\[1\]}) }
        end

        context 'with empty string for service_name' do
          let(:params) { { service_name: '' } }

          it { is_expected.to compile.and_raise_error(%r{expects a String\[1\]}) }
        end

        context 'with relative path for basedir' do
          let(:params) { { basedir: 'relative/path' } }

          it { is_expected.to compile.and_raise_error(%r{expects a Stdlib::Absolutepath}) }
        end

        context 'with relative path for mbuffer_path' do
          let(:params) { { mbuffer_path: 'relative/path' } }

          it { is_expected.to compile.and_raise_error(%r{expects a Stdlib::Absolutepath}) }
        end

        context 'with invalid plans parameter (not hash)' do
          let(:params) { { plans: 'not_a_hash' } }

          it { is_expected.to compile.and_raise_error(%r{expects a Hash}) }
        end

        context 'with valid plans hash' do
          let(:params) do
            {
              plans: {
                'test_plan' => {
                  'config_src' => 'tank/test',
                },
              },
            }
          end

          it { is_expected.to compile }
        end
      end

      # Test OS family validation logic
      describe 'OS family validation' do
        context 'with supported OS family' do
          it { is_expected.to compile }
        end

        context 'with unsupported OS family' do
          let(:facts) do
            os_facts.merge(
              {
                os: {
                  'family' => 'Debian',
                  'name' => 'Ubuntu',
                },
              },
            )
          end

          it { is_expected.to compile.and_raise_error(%r{OS Family Debian unsupported}) }
        end
      end

      # Test modern class containment pattern (no more anchors)
      describe 'class containment' do
        it { is_expected.to contain_class('znapzend::install') }
        it { is_expected.to contain_class('znapzend::service') }
        it { is_expected.to contain_class('znapzend::plans') }

        # Verify that anchor resources are NOT present (modernized)
        it { is_expected.not_to contain_anchor('znapzend::begin') }
        it { is_expected.not_to contain_anchor('znapzend::end') }
      end
    end
  end
end
