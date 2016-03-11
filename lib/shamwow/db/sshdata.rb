require 'data_mapper'

module Shamwow
  class SshData
    include DataMapper::Resource


    property :id,               Serial
    property :hostname,         String
    property :os,               String
    property :os_polltime,      DateTime
    property :chefver,          String
    property :chefver_polltime, DateTime

    attr_reader :os_polltime
    attr_reader :chefver_polltime
  end
end