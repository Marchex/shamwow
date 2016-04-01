
module Shamwow; module SshTask; class Chef_lsof_count
    #
    def self.command
      'sudo lsof -p $(pgrep -o chef-client) | wc -l'
    end
    #
    # commoon output from command
    #   ffi-yajl/json_gem is deprecated, these monkeypatches will be dropped shortly
    #   Chef: 11.16.4

    def self.parse(host, data)
      begin
        count = data.match(/\s*(\d+)\s*/)[1]
      rescue
        Shamwow::Ssh._save_error(host, 'SshTask::Chef_lsof_count', "#{$ERROR_INFO} #{data}")
      end

      {
          :chef_lsof_count => count,
          :chef_lsof_polltime => Time.now
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