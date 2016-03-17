
module Shamwow; module SshTask;
class Chef_start
                                  #
  def self.command
    'sudo /etc/init.d/chef-client start'
  end
  #
  # commoon output from command

  def self.parse(host, data)
  {
        :chefver => 'start_chef_client',
        :chef_whyrun_full => data,
        :chef_whyrun_polltime => Time.now
    }
  end

  def self.save(repo, host, attributes)
    o = repo["#{host}"]
    o.sshdata_chef_whyrun.new(attributes)
    o.save
  end
end

end;
end;