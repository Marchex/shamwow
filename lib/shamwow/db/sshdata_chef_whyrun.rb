require 'data_mapper'

module Shamwow
  class SshdataChefWhyrun
    include DataMapper::Resource

    property :id,                         Serial
    property :chef_whyrun_full,           Text
    property :chef_whyrun_polltime,       DateTime

    belongs_to :ssh_data
  end
end