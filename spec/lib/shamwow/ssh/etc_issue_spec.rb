require 'rspec'
require 'shamwow/ssh'
require 'shamwow/db/sshdata'

describe 'Ssh/Etc_issue' do
  before(:context) do
    #
    # Arrange
    @time_now = Time.now
  end

  it 'should parse a centos 6.4 /etc/issue' do
    #
    # Arrange
    allow(Time).to receive(:now).and_return(@time_now)
    #
    # # Act
    result = Shamwow::SshTask::Os_version.parse('host', 'CentOS release 6.4 (Final)
Kernel \r on an \m
')
    #
    # Assert
    expect(result).to eq({:os=>"CentOS release 6.4 (Final)",:os_polltime=>@time_now})
  end

  it 'should parse a Debian 5 /etc/issue' do
    #
    # Arrange
    allow(Time).to receive(:now).and_return(@time_now)
    #
    # # Act
    result = Shamwow::SshTask::Os_version.parse('foo', 'Debian GNU/Linux 5.0 \n \l
')
    #
    # Assert
    expect(result).to eq({:os=>"Debian GNU/Linux 5.0",:os_polltime=>@time_now})
  end

  it 'should parse an Ubuntu /etc/issue' do
    #
    # Arrange
    allow(Time).to receive(:now).and_return(@time_now)
    #
    # # Act
    result = Shamwow::SshTask::Os_version.parse('foo', 'Ubuntu 12.04.5 LTS \n \l
')
    #
    # Assert
    expect(result).to eq({:os=>"Ubuntu 12.04.5 LTS",:os_polltime=>@time_now})
  end
end
