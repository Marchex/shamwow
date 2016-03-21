
module Shamwow; module SshTask; class Chef_stacktrace
                                  #
  def self.command
    'sudo cat /var/chef/cache/chef-stacktrace.out'
  end
  #
  # commoon output from command

  def self.parse(host, data)
    begin
      gentime = data.match(/Generated at (\d\d\d\d-\d\d-\d\d \d\d:\d\d:\d\d\s+[\+-]\d+)/)[1]
    rescue
      Shamwow::Ssh._save_error(host, 'SshTask::Chef_stacktrace/gentime', "#{$ERROR_INFO} #{data}")

    end
    begin
      method  = data.match(/^([^G\/].+)$/)[1].strip
    rescue
      Shamwow::Ssh._save_error(host, 'SshTask::Chef_stacktrace/method', "#{$ERROR_INFO} #{data}")

    end

    {
        :chef_strace_method => method,
        :chef_strace_gentime => gentime.nil? ? nil : Time.parse(gentime),
        :chef_strace_full => data,
        :chef_strace_polltime => Time.now
    }
  end

  def self.save(repo, host, attributes)
    o = repo["#{host}"]
    o.attributes = attributes
    o.save
  end
end

end;
end;