require 'data_mapper'

module Shamwow
  class SshData
    include DataMapper::Resource

    property :id,                         Serial
    property :hostname,                   String
    property :os,                         String
    property :os_polltime,                DateTime
    property :chefver,                    String
    property :chefver_polltime,           DateTime
    property :chef_strace_method,         String, :length => 400
    property :chef_strace_gentime,        DateTime
    property :chef_strace_full,           Text
    property :chef_strace_polltime,       DateTime

    has n, :sshdata_exec_output

    attr_reader :os_polltime
    attr_reader :chefver_polltime
  end
end