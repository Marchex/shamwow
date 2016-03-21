
module Shamwow; module SshTask; class Etc_issue
    #
    def self.command
      'cat /etc/issue'
    end
    #
    # commoon output from command

    def self.parse(host, data)
      begin
        ver = data.gsub(/(\\\w)/, '').gsub(/^Kernel.*$/,'').strip
      rescue
        Shamwow::Ssh._save_error(host, 'SshTask::Etc_issue/ver', "#{$ERROR_INFO} #{data}")

      end
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