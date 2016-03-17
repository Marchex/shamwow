
module Shamwow; module SshTask;
class Gem_list_ldap
                                  #
  def self.command
    '/opt/chef/embedded/bin/gem list |grep net-ldap'
  end
  #
  # commoon output from command

  def self.parse(host, data)
  {
        :chefver => 'gem_list_ldap',
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