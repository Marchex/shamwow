require 'shamwow/db/node'
require 'shamwow/db/sshdata'
require 'data_mapper'
require 'dm-migrations'

module Shamwow
  class Db

    def initialize(dm_conn, debug)
      DataMapper::Logger.new($stdout, :debug) if debug
      DataMapper.setup(:default, dm_conn)
      DataMapper.finalize
    end


    def bootstrap_db
      DataMapper.auto_migrate!
    end

    def create_node node
      Node.first_or_create({ :hostname => node[:hostname]}, node)
    end

    def create_sshdata node
      #SshData.first_or_create({ :hostname => node[:hostname]}, node)
      node.first_or_create
    end

  end
end

# db.create_node ({
#     :hostname => ch[:host],
#     :os => 'ubuntu',
#     :chefver => data,
#     :firstseen => Time.now,
#     :lastseen => Time.now
# })