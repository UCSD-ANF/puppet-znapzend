require 'spec_helper'

describe 'znapzend', :type => :class do

    it { should contain_class('znapzend::install') }
    it { should contain_class('znapzend::service') }
    it { should contain_class('znapzend::config') }

end
