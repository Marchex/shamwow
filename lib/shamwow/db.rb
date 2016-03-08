require 'shamwow/db/node'
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
    end
end