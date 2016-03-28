require 'shamwow/db/node'
require 'shamwow/db/sshdata'
require 'shamwow/db/errordata'
require 'shamwow/db/sshdata_exec_output'
require 'shamwow/db/products'
require 'data_mapper'
require 'dm-migrations'

module Shamwow
  class Db

    def initialize(dm_conn, debug)
      #DataMapper::Logger.new($stdout, :debug) if debug
      DataMapper.setup(:default, dm_conn)
      DataMapper.finalize
    end


    def bootstrap_db
      DataMapper.auto_upgrade!
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
