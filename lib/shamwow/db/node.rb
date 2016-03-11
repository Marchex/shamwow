require 'data_mapper'

module Shamwow
  class Host
    include DataMapper::Resource

    property :id,               Serial
    property :hostname,         String
    property :firstseen,        DateTime
    property :lastseen,         DateTime
  end
end