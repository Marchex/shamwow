
module Shamwow; module SshTask; class Chef_verify_running_version
    #
    def self.command
      'sudo /usr/bin/lsof -p $(/usr/bin/pgrep chef-client)'
    end
    #
    # commoon output from command
    #   chef-clie 27653 root  txt    REG  202,1     12031 6033542 /opt/chef/embedded/bin/ruby
    #   Chef: 12.5.1

    def self.parse(host, data)
      begin
        rubysize = data.match(/\s+(\d+)\s+\d+\s+\/opt\/chef\/embedded\/bin\/ruby/)[1]
      rescue
        Shamwow::Ssh._save_error(host, 'SshTask::Chef_whyrun/chefver', "#{$ERROR_INFO} #{data}")

      end
      {
          :chefver => 'verify_running_version',
          :chef_whyrun_full => data[0..65000],
          :chef_whyrun_polltime => Time.now,
      }
    end
    def self.save(repo, host, attributes)
      o = repo["#{host}"]
      o.sshdata_chef_whyrun.new(attributes)
      o.save
    end
  end

end;
end;