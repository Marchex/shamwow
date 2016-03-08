require 'data_mapper'

module Shamwow
    class Node
      include DataMapper::Resource

      property :id,               Serial
      property :hostname,         String
      property :os,               String
      property :chefver,          String
      property :firstseen,        DateTime
      property :lastseen,         DateTime
    end
end