
module Shamwow; module SshTask;
class Chef_upgrade
                                  #
  def self.command
    'curl -L https://www.chef.io/chef/install.sh | sudo bash -s -- -v 12.6.0'
  end
  #
  # commoon output from command

  def self.parse(host, data)
  {
        :chefver => 'upgrade_to_12.6.0',
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