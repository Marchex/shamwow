
module Shamwow; module SshTask; class Os_version
    #
    def self.command
      'cat /etc/redhat-release 2>/dev/null || cat /etc/issue 2>/dev/null || cat /etc/lsb-release | grep DESC'
    end
    #
    # commoon output from command

    def self.parse(host, data, db)
      begin
        ver = data.gsub(/(\\\w)/, '') # from /etc/issue
                  .gsub(/^Kernel.*$/,'')  # from /etc/issue
                  .gsub(/DISTRIB_DESCRIPTION\=\"/,'') # from /etc/lsb-release
                  .gsub(/\"/,'')  # from /etc-lsb-release
                  .strip
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