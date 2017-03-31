
module Shamwow; module SshTask;
class Nrpe_upgrade_checkchef
                                  #
  def self.command
    'sudo scp -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no REDACTED@REDACTED.com:/tmp/check_chef_fatal.sh /site/general-nrpe/binary/check_chef_fatal.sh'
  end
  #
  # commoon output from command

  def self.parse(host, data, db)
  {
        :category => 'upgrade_check_chef_fatal',
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

end
end