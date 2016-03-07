require 'data_mapper'

class ChefNode
  include DataMapper::Resource

  property :id,               Serial
  property :hostname,         String
  property :os,               String
  property :chefver,          String
  property :firstseen,        DateTime
  property :lastseen,         DateTime
end