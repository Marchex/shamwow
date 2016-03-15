
module Shamwow; module SshTask; class Etc_issue
    #
    def self.command
      'cat /etc/issue'
    end
    #
    # commoon output from command
    #   ffi-yajl/json_gem is deprecated, these monkeypatches will be dropped shortly
    #   Chef: 11.16.4

    def self.parse(data)
      ver = data.gsub(/(\\\w)/, '').gsub(/^Kernel.*$/,'').strip
      {
          :os => ver,
          :os_polltime => Time.now
      }
    end
  end

end;
end;