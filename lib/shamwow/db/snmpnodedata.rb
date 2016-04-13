require 'data_mapper'

module Shamwow
  class SnmpNodeData
    include DataMapper::Resource

    property :id,                 Serial
    property :hostname,           String
    property :snmp_loc,           String
    property :ip,                 String,   :length => 15
    property :os_model,           String
    property :snmp_desc,          Text
    property :serial,             String
    property :snmp_name,          String
    property :hw_make,            String
    property :os_make,            String
    property :hw_model,           String
    property :polltime,           DateTime

    has n, :snmp_node_iface

  end
end