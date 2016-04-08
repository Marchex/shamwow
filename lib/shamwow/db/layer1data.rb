require 'data_mapper'

module Shamwow
  class Layer1Data
    include DataMapper::Resource

    property :ethswitch,          String,   :key => true
    property :interface,          String,   :key => true
    property :linkstate,          String
    property :description,        String
    property :polltime,           DateTime

    #has n, :sshdata_exec_output

  end
end