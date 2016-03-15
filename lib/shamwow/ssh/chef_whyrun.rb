
module Shamwow; module SshTask; class Chef_whyrun
                                  #
  def self.command
    'sudo chef-client --why-run'
  end
  #
  # commoon output from command

  def self.parse(data)
    {
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