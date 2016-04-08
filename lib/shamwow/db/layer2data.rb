require 'data_mapper'

module Shamwow
  class Layer2Data
    include DataMapper::Resource

    property :ethswitch,          String,   :key => true
    property :interface,          String,   :key => true
    property :macaddress,         String,   :key => true, :length => 12
    property :macprefix,          String,   :length => 6
    property :vlan,               String
    property :polltime,           DateTime

    #has n, :sshdata_exec_output

  end
end