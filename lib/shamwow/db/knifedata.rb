require 'data_mapper'

module Shamwow
  class KnifeData
    include DataMapper::Resource

    property :id,                 Serial
    property :name,               String, length: 200
    property :chefenv,            String, length: 100
    property :ip,                 String, length: 15
    property :ohai_time,          DateTime
    property :platform,           String
    property :platform_version,   String
    property :polltime,           DateTime

  end
end