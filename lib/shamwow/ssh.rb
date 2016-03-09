require 'net/ssh/multi'
require 'shamwow/db'


module Shamwow
  class Ssh

    def initialize
      @session = Net::SSH::Multi::Session.new
      @session.on_error = :ignore
      @hosts = { }
      @debug = 1
    end

    def add_host(host)
      # get persistant object
      _load_sshdata host
      # setup ssh session
      @session.use "jcarter@#{host}"
    end

    def count_hosts
      @session.servers.count
    end

    def execute
      _define_execs
      @session.loop
    end

    def save
      @hosts.each_value do |o|
        o.save
      end
    end

    def _load_sshdata(host)
      o = SshData.first_or_new({:hostname => host})
      @hosts["#{host}"] = o

    end

    def _define_execs
      @session.exec 'chef-client --version' do |ch, stream, data|
        puts "[#{ch[:host]} : #{stream}] #{data}"
        _parse_chef_client ch[:host], data
      end

      @session.exec 'cat /etc/lsb-release' do |ch, stream, data|
        puts "[#{ch[:host]} : #{stream}] #{data}"
        begin
          _parse_lsb_release ch[:host], data
        rescue => e
          puts "------#{e.message}"
        end

      end

    end

    def _parse_chef_client(host, data)
      ver = (data.split " ")[1].strip
      o = @hosts["#{host}"]
      o.attributes = { :chefver => ver }
    end


    def _parse_lsb_release(host, data)
      ver = data.match(/DISTRIB_DESCRIPTION=(.*)/)[1]
      ver = ver.strip().gsub! /"/, ''
      o = @hosts["#{host}"]
      o.attributes = { :os => ver }
    end

  end
end