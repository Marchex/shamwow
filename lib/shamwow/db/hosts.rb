require 'data_mapper'

module Shamwow
  class Host
    include DataMapper::Resource

    property :id,               Serial
    property :hostname,         String, :length => 150
    property :domain,           String
    property :product,          String
    property :environment,      String
    property :severity,         Integer
    property :ssh_lastseen,     DateTime
    property :knife_lastseen,   DateTime
    property :dns_lastseen,     DateTime
    property :ssh_scan,         Boolean
    property :notes,            Text

  end
end