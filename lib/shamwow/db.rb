require 'shamwow/db/hosts'
require 'shamwow/db/sshdata'
require 'shamwow/db/errordata'
require 'shamwow/db/sshdata_exec_output'
require 'shamwow/db/products'
require 'shamwow/db/dnsdata'
require 'shamwow/db/layer1data'
require 'shamwow/db/layer2data'
require 'shamwow/db/layer3data'
require 'shamwow/db/knifedata'
require 'shamwow/db/snmpnodedata'
require 'shamwow/db/snmpnodeiface'
require 'shamwow/db/logdata'
require 'data_mapper'
require 'dm-migrations'

module Shamwow
  class Db

    def initialize(dm_conn, debug)

      @errors = []
      @logs = []
      @errortypes = {}
      @logtypes = {}
      #DataMapper::Logger.new($stdout, :debug) if debug
      DataMapper.setup(:default, dm_conn)
      DataMapper::Model.raise_on_save_failure = true
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

    def save_error(host, action, message)
      o = ErrorData.new
      o.attributes= {
          :timestamp => Time.now,
          :hostname => host,
          :action => action,
          :message => message
      }
      o.save
      @errors.push(o)
      @errortypes["#{message}"] ||= 0
      @errortypes["#{message}"] += 1
    end

    def save_log(type, name, action, message)
      o = LogData.new
      o.attributes= {
          :timestamp => Time.now,
          :name => name,
          :type => type,
          :action => action,
          :message => message
      }
      o.save
      @logs.push(o)
      @logtypes["#{message}"] ||= 0
      @logtypes["#{message}"] += 1
    end

    def finalize

      @errortypes.each do |type, count|
        puts "Error type: #{type}: #{count}"
      end
    end
  end
end
