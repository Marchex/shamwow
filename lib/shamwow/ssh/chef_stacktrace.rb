
module Shamwow; module SshTask; class Chef_stacktrace
                                  #
  def self.command
    'sudo cat /var/chef/cache/chef-stacktrace.out'
  end
  #
  # commoon output from command
  #   ffi-yajl/json_gem is deprecated, these monkeypatches will be dropped shortly
  #   Chef: 11.16.4

  def self.parse(data)
    gentime = data.match(/Generated at (\d\d\d\d-\d\d-\d\d \d\d:\d\d:\d\d\s+[\+-]\d+)/)[1]
    method  = data.match(/^([^G\/].+)$/)[1].strip

    {
        :chef_strace_method => method,
        :chef_strace_gentime => gentime.nil? ? nil : Time.parse(gentime),
        :chef_strace_full => data,
        :chef_strace_polltime => Time.now
    }
  end
end

end;
end;