require 'rspec'
require 'shamwow/ssh'
require 'shamwow/db/sshdata'

describe 'Ssh/Chef_stacktrace' do
  before(:context) do
    #
    # Arrange
    @time_now = Time.now
  end

  it 'should parse a chef stacktrace' do
    #
    # Arrange
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
