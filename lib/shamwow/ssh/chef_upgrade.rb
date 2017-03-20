
module Shamwow; module SshTask;
class Chef_upgrade
                                  #
  def self.command
    #'curl -L https://www.chef.io/chef/install.sh | sudo bash -s -- -v 12.18.31'  # for nodes not on admin network
    'sudo rpm -U /tmp/chef-12.18.31-1.el7.x86_64.rpm'
  end
  #
  # commoon output from command

  def self.parse(host, data, db)
  {
        :category => 'upgrade_to_12.18.31',
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
