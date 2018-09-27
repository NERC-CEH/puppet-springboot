require 'spec_helper'

describe 'springboot::service' do 
 
  let(:params) {{ :artifact => 'test-artifact', :env => {'env1'=>'val1','env2'=>'val2'} } }

  context 'create upstart entry for ubuntu14' do
    let(:facts) {{ :osfamily => 'Debian', :operatingsystem => 'Ubuntu', :operatingsystemmajrelease => '14.04' }}

    it { is_expected.to compile }
    it { is_expected.to contain_file('/etc/init/test-artifact.conf') }
  end
  
  context 'create systemd service for ubuntu16' do
    let(:facts)  {{ :osfamily => 'Debian', :operatingsystem => 'Ubuntu', :operatingsystemmajrelease => '16.04'}}

    it { is_expected.to compile }
    it { is_expected.to contain_file('/etc/systemd/system/test-artifact.service') }
  end
end
