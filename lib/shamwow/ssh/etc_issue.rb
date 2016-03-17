
module Shamwow; module SshTask; class Etc_issue
    #
    def self.command
      'cat /etc/issue'
    end
    #
    # commoon output from command

    def self.parse(host, data)
    ver = data.gsub(/(\\\w)/, '').gsub(/^Kernel.*$/,'').strip
      {
          :os => ver,
          :os_polltime => Time.now
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