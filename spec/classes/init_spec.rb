require 'spec_helper'
describe 'customer-syslog' do

  context 'with defaults for all parameters' do
    it { should contain_class('customer-syslog') }
  end
end
