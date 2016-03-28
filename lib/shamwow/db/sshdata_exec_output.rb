require 'data_mapper'

module Shamwow
  class SshdataExecOutput
    include DataMapper::Resource

    property :id,                         Serial
    property :category,                   String
    property :chef_exec_output,           Text
    property :chef_exec_polltime,       DateTime

    belongs_to :ssh_data
  end
end