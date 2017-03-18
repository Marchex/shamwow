
module Shamwow; module SshTask; class Chef_verify_running_version
    #
    def self.command
      'sudo /usr/bin/lsof -p $(/usr/bin/pgrep -o chef-client)'
    end

    def self.parse(host, data, db)
      begin
        rubysize = data.match(/\s+(\d+)\s+\d+\s+\/opt\/chef\/embedded\/bin\/ruby/)[1]
      rescue
        db.save_error(host, 'SshTask::Chef_verify_running_version/embedded_size', "#{$ERROR_INFO} #{data}")
      end

      {
          :category => 'verify_running_version',
          :chef_exec_output => data[0..65000],
          :chef_exec_polltime => Time.now,
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
