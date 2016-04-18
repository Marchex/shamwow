require 'data_mapper'

module Shamwow
  class SnmpNodeData
    include DataMapper::Resource

    property :id,                 Serial
    property :hostname,           String,   :length => 200
    property :snmp_loc,           String,   :length => 200
    property :ip,                 String,   :length => 15
    property :os_model,           String,   :length => 200
    property :snmp_desc,          Text
    property :serial,             String,   :length => 200
    property :snmp_name,          String,   :length => 200
    property :hw_make,            String,   :length => 200
    property :os_make,            String,   :length => 200
    property :hw_model,           String,   :length => 200
    property :polltime,           DateTime

    has n, :snmp_node_iface

  end
end