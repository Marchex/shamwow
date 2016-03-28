
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
        :category => 'gem_list_ldap',
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