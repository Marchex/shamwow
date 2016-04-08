require 'data_mapper'

module Shamwow
  class Layer3Data
    include DataMapper::Resource

    property :ipgateway,          String,   :key => true
    property :port,               String,   :key => true
    property :macaddress,         String,   :key => true, :length => 12
    property :ipaddress,          String,   :key => true, :length => 15
    property :macprefix,          String,   :length => 6
    property :rdns,               String,    :length => 200
    property :polltime,           DateTime

    #has n, :sshdata_exec_output

  end
end