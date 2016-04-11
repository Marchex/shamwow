require 'data_mapper'

module Shamwow
  class DnsData
    include DataMapper::Resource

    property :id,           Serial
    property :name,         String
    property :ttl,          Integer
    property :class,        String
    property :type,         String
    property :address,      String, length: 500
    property :ipaddress,    String, length: 15
    property :polltime,     DateTime
    #
    property :domain,       String, length: 100
    property :classB,       String, length: 7
    property :classC,       String, length: 11

  end
end