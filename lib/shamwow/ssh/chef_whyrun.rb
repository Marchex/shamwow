
module Shamwow; module SshTask; class Chef_whyrun
                                  #
  def self.command
    'sudo chef-client'
  end
  #
  # commoon output from command

  def self.parse(host, data)
  begin
      chefver = data.match(/Starting Chef Client, version ([\w\.]+)/)[1]
  rescue
    Shamwow::Ssh._save_error(host, 'SshTask::Chef_whyrun/chefver', "#{$ERROR_INFO} #{data}")

  end
    {
        :category => chefver,
        :chef_exec_output => data[0..65000],
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