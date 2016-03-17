module Shamwow; module SshTask;
class Chef_chmod_stacktrace

  def self.command
    'sudo chmod 644 /var/chef/cache/chef-stacktrace.out; ls -l /var/chef/cache/chef-stacktrace.out'
  end

  def self.parse(host, data)
    {
        :chefver => 'chef_chmod_stacktrace',
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