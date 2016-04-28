
module Shamwow; module SshTask; class Etc_issue
    #
    def self.command
      'cat /etc/issue'
    end
    #
    # commoon output from command

    def self.parse(host, data, db)
      begin
        ver = data.gsub(/(\\\w)/, '').gsub(/^Kernel.*$/,'').strip
      rescue
        db.save_error(host, 'SshTask::Etc_issue/ver', "#{$ERROR_INFO} #{data}")

      end
      {
          :os => ver[0..49],
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