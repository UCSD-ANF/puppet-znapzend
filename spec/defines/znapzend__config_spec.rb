require 'spec_helper'

describe 'znapzend::config', :type => :define do
  
  let :pre_condition do
    'class { "znapzend": 
       service_conf_dir => "/usr/local/etc/znapzend",
       user             => "znapzend",
       group            => "znapzend",
    }'
  end

  config_file='tank_foobar'

  let(:title) { config_file }
  
  let(:params) {{
    :config_file => config_file,
    :config_src  => config_file,
  }}
  ['RedHat','FreeBSD','Solaris'].each do |system|
    context "when on system #{system}" do
      if system == 'CentOS'
        let(:facts) {{
          :osfamily        => 'RedHat',
          :operatingsystem => system,
        }}
      else
        let(:facts) {{
          :osfamily        => system,
          :operatingsystem => system,
        }}
      end 
      it { should contain_file('/usr/local/etc/znapzend/tank_foobar').with(
          :owner  => "znapzend",
          :group  => "znapzend",
          :notify => "Exec[load_tank_foobar]",
       ) }
    end
  end

end
