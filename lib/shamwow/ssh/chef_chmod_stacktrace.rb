module Shamwow; module SshTask;
class Chef_chmod_stacktrace

  def self.command
    'sudo chmod 644 /var/chef/cache/chef-stacktrace.out; ls -l /var/chef/cache/chef-stacktrace.out'
  end

  def self.parse(host, data, db)
    {
        :category => 'chef_chmod_stacktrace',
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