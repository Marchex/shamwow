
module Shamwow; module SshTask; class Chef_run
                                  #
  def self.command
    'sudo chef-client'
  end
  #
  # commoon output from command

  def self.parse(host, data, db)
  begin
      # this was used for the category, but that purpose doesn't make sense anymore
      if m = data.match(/Starting Chef Client, version ([\w\.]+)/)
        chefver = m[1]
      end
      if m = data.match(/Starting Chef Run for/)
        chefver = "< 11.0"
      end
  rescue
    db.save_error(host, 'SshTask::Chef_run/chefver', "#{$ERROR_INFO} #{data}")

  end
    {
        :category => 'chef_run',
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