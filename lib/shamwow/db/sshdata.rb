require 'data_mapper'

module Shamwow
  class SshData
    include DataMapper::Resource

    property :id,                         Serial
    property :hostname,                   String, :length => 100
    property :os,                         String
    property :os_polltime,                DateTime
    property :chefver,                    String
    property :chefver_polltime,           DateTime
    property :chef_strace_method,         Text
    property :chef_strace_gentime,        DateTime
    property :chef_strace_full,           Text
    property :chef_strace_polltime,       DateTime
    property :chef_lsof_count,            Integer
    property :chef_lsof_polltime,         DateTime
    property :nrpe_chefcheck_checksum,    String, :length => 100
    property :nrpe_chefcheck_fileinfo,    String, :length => 100
    property :nrpe_checksum_polltime,     DateTime
    property :chef_server_url,            String, :length => 150
    property :chef_server_url_polltime,   DateTime

    has n, :sshdata_exec_output

    attr_reader :os_polltime
    attr_reader :chefver_polltime
  end
end