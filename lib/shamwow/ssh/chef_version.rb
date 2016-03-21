
module Shamwow; module SshTask; class Chef_version
    #
    def self.command
      'chef-client --version'
    end
    #
    # commoon output from command
    #   ffi-yajl/json_gem is deprecated, these monkeypatches will be dropped shortly
    #   Chef: 11.16.4

    def self.parse(host, data)
      begin
        ver = data.match(/Chef: ([\w\.]+)/)[1]
      rescue
        Shamwow::Ssh._save_error(host, 'SshTask::Chef_version', "#{$ERROR_INFO} #{data}")
      end

      {
          :chefver => ver,
          :chefver_polltime => Time.now
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