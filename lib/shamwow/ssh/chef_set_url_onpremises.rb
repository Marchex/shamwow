
module Shamwow; module SshTask;
class Chef_set_url_onpremises
                                  #
  def self.command
    'sudo perl -pi -e \'s/chef_server_url\s+\"([\w\:\/\.]+)\"/chef_server_url \"https\:\/\/chef.marchex.com\/organizations\/outhouse\"/\' /etc/chef/client.rb'
  end
  #
  # commoon output from command

  def self.parse(host, data, db)
  {
        :category => 'set_url_onpremises',
        :chef_exec_output => data,
        :chef_exec_polltime => Time.now
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
