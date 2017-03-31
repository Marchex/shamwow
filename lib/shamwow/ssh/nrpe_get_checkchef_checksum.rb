
module Shamwow; module SshTask;
class Nrpe_get_checkchef_checksum
                                  #
  def self.command
    '/usr/bin/md5sum /site/general-nrpe/binary/check_chef_fatal.sh && ls -l /site/general-nrpe/binary/check_chef_fatal.sh'
  end

  def self.parse(host, data, db)
    begin
      md5data = data.match(/^(\w+)\s+\/site\/general\-nrpe\/binary\/check_chef_fatal.sh/)[1]
    rescue
      db.save_error(host, 'SshTask::Nrpe_get_checkchef_checksum/md5parse', "#{$ERROR_INFO} #{data}")
    end
    begin
      lsdata = data.match(/^([\-\w:\s]+\s+[\d:]+)\s+\/site\/general\-nrpe\/binary\/check_chef_fatal.sh/)[1]
    rescue
      db.save_error(host, 'SshTask::Nrpe_get_checkchef_checksum/lsparse', "#{$ERROR_INFO} #{data}")
    end

    {
      :nrpe_chefcheck_checksum => md5data,
      :nrpe_chefcheck_fileinfo => lsdata,
      :nrpe_checksum_polltime  => Time.now
    }
  end

  def self.save(repo, host, attributes)
    o = repo["#{host}"]
    o.attributes = attributes
    o.save
  end
end

end
end