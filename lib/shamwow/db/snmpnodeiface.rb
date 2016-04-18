require 'data_mapper'

module Shamwow
  class SnmpNodeIface
    include DataMapper::Resource

    property :id,                 Serial
    property :ifacename,          String, :length => 250
    property :macaddr,            String, :length => 20
    property :description,        Text
    property :speed,              String
    property :ipaddr,             String, :length => 500
    property :state,              String, :length => 100
    property :admin_state,        String
    property :type,               String
    property :polltime,           DateTime

    belongs_to :snmp_node_data
  end
end