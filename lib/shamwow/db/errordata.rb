require 'data_mapper'
module Shamwow

  class ErrorData
    include DataMapper::Resource

    property :id,           Serial
    property :timestamp,    DateTime
    property :hostname,     String
    property :action,       String, :length => 200
    property :message,      Text
  end

end
