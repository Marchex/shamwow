module Shamwow; module SshTask;
class Chef_stop

  def self.command
    'sudo pkill -9 chef-client && sudo rm -f /var/run/chef/client.pid; ps -ef | grep chef-client'
  end

  def self.parse(host, data)
  {
        :category => 'stop_chef_client',
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