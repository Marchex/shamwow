
module Shamwow; module SshTask;
class Chef_start
                                  #
  def self.command
    'sudo /etc/init.d/chef-client start'
  end
  #
  # commoon output from command

  def self.parse(host, data, db)
  {
        :category => 'start_chef_client',
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