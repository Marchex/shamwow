
module Shamwow; module SshTask; class Chef_server_url
    #
    def self.command
      'grep -i chef_server_url /etc/chef/client.rb'
    end
    #
    # commoon output from command
    # jcarter@tools1:~$ grep -i chef_server_url /etc/chef/client.rb
    # chef_server_url "https://chef.marchex.com/organizations/outhouse"

    def self.parse(host, data, db)
      begin
        url = data.match(/chef_server_url \"(http[\w\.\:\/]+)\"/)[1]
      rescue
        db.save_error(host, 'SshTask::Chef_server_url', "#{$ERROR_INFO} #{data}")
      end

      {
          :chef_server_url => url,
          :chef_server_url_polltime => Time.now
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