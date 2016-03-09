require 'rspec'
require_relative '../../../lib/shamwow/ssh'
require_relative '../../../lib/shamwow/db/sshdata'
describe 'Ssh' do

  it 'should parse lsb release for the OS version' do
    #
    # Arrange
    sshdata = instance_double("Shamwow::SshData", :hostname => 'foo')
    allow(Shamwow::SshData).to receive(:first_or_new) { sshdata }
    allow(sshdata).to receive(:firstseen)
    allow(sshdata).to receive(:lastseen)
    allow(sshdata).to receive(:attributes=).with(any_args)
    o = Shamwow::Ssh.new
    o.add_host('foo')

    ## Act
    o._parse_lsb_release('foo', 'DISTRIB_ID=Ubuntu
DISTRIB_RELEASE=12.04
DISTRIB_CODENAME=precise
DISTRIB_DESCRIPTION="Ubuntu 12.04.5 LTS"')

    ## Assert
    expect(sshdata).to have_received(:attributes=).with({:os=>"Ubuntu 12.04.5 LTS"})
  end

  it 'should catch errors parsing lsb release' do
    #
    # Arrange
    sshdata = instance_double("Shamwow::SshData", :hostname => 'foo')
    allow(Shamwow::SshData).to receive(:first_or_new) { sshdata }
    allow(sshdata).to receive(:firstseen)
    allow(sshdata).to receive(:lastseen)
    allow(sshdata).to receive(:attributes=).with(any_args)
    o = Shamwow::Ssh.new
    o.add_host('foo')
    #
    # Act & Assert
    expect { o._parse_lsb_release('foo', '') }.to raise_error(NoMethodError)
    expect { o._parse_lsb_release('foo', "\n") }.to raise_error(NoMethodError)
  end
end