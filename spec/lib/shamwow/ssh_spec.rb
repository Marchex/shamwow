require 'rspec'
require_relative '../../../lib/shamwow/ssh'
require_relative '../../../lib/shamwow/db/sshdata'

describe 'Ssh' do
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
    result = Shamwow::SshTask::Etc_issue.parse('host', 'CentOS release 6.4 (Final)
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
    result = Shamwow::SshTask::Etc_issue.parse('foo', 'Debian GNU/Linux 5.0 \n \l
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
    result = Shamwow::SshTask::Etc_issue.parse('foo', 'Ubuntu 12.04.5 LTS \n \l
')
    #
    # Assert
    expect(result).to eq({:os=>"Ubuntu 12.04.5 LTS",:os_polltime=>@time_now})
  end

  it 'should parse a chef stacktrace' do
    #
    # Arrange
    ssh = Shamwow::Ssh.new
    allow(ssh).to receive(:_save_ssh_data)
    allow(Time).to receive(:now).and_return(@time_now)
    #
    # # Act
    result = Shamwow::SshTask::Chef_stacktrace.parse('foo', 'Generated at 2016-01-28 19:48:48 +0000
ChefVault::Exceptions::SecretDecryption: escrow/certificates is not encrypted with your public key.  Contact an administrator of the vault item to encrypt for you!
/opt/chef/embedded/lib/ruby/gems/1.9.1/gems/chef-va (...)')
    #
    # Assert
    expect(result).to eq({:chef_strace_method=> "ChefVault::Exceptions::SecretDecryption: escrow/certificates is not encrypted with your public key.  Contact an administrator of the vault item to encrypt for you!",
                          :chef_strace_gentime=>Time.parse('2016-01-28 11:48:48.000000000 -0800'),
                          :chef_strace_full=> "Generated at 2016-01-28 19:48:48 +0000\nChefVault::Exceptions::SecretDecryption: escrow/certificates is not encrypted with your public key.  Contact an administrator of the vault item to encrypt for you!\n/opt/chef/embedded/lib/ruby/gems/1.9.1/gems/chef-va (...)",
                          :chef_strace_polltime=>@time_now})
  end

end
