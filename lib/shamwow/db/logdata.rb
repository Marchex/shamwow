require 'data_mapper'
module Shamwow

  class LogData
    include DataMapper::Resource

    property :id,           Serial
    property :timestamp,    DateTime
    property :type,         String
    property :name,         String, :length => 200
    property :action,       String
    property :message,      Text
  end

end