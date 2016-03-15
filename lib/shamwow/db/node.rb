require 'data_mapper'

module Shamwow
  class Host
    include DataMapper::Resource

    property :id,               Serial
    property :hostname,         String
    property :domain,           String
    property :product,          String
    property  :severity,        Integer
    property :datacenter,       Integer
    property :lastseen,         DateTime
    property :comfort,          Integer
    property :cohort,           Integer
  end
end