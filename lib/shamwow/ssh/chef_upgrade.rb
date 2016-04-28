
module Shamwow; module SshTask;
class Chef_upgrade
                                  #
  def self.command
    'curl -L https://www.chef.io/chef/install.sh | sudo bash -s -- -v 12.2.1'
    #'curl -L https://www.chef.io/chef/install.sh | sudo bash -s -- -v 12.6.0'
    #'sudo yum install -y --nogpg chef.x86_64'
  end
  #
  # commoon output from command

  def self.parse(host, data)
  {
        :category => 'upgrade_to_12.6.0',
        :chef_exec_output => data,
        :chef_exec_polltime => Time.now
    }
  end

  def self.save(repo, host, attributes)
    o = repo["#{host}"]
    o.sshdata_exec_output.new(attributes)
    o.save
  end
end

end;
end;
