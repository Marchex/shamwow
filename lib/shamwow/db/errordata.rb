require 'data_mapper'
module Shamwow

  class ErrorData
    include DataMapper::Resource

    property :id,           Serial
    property :timestamp,    DateTime
    property :hostname,     String, :length => 250
    property :action,       String, :length => 250
    property :message,      Text
  end

end
