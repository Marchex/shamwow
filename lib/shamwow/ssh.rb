require 'net/ssh/multi'
require 'shamwow/db'
require 'net/ssh/gateway'


module Shamwow
  class Ssh

    def initialize
      handler = Proc.new do |server|
        server[:connection_attempts] ||= 0
        if server[:connection_attempts] < 0
          server[:connection_attempts] += 1
          throw :go, :retry
        else
          puts "ERROR: #{server.to_s} -- #{$ERROR_INFO}"
          throw :go
        end
      end
      @session = Net::SSH::Multi::Session.new
      @session.on_error = handler

      @session.concurrent_connections = 50
      @session.via 'vmbuilder1.sea1.marchex.com', 'jcarter'
      @hosts = { }
      @debug = 1
    end

    def add_host(host)
      # get persistant object
      _load_sshdata host
      # setup ssh session
      @session.use "jcarter@#{host}", :timeout => 10
    end

    def count_hosts
      @session.servers.count
    end

    def execute
      _define_execs
      block = Proc.new do |c|
        c.busy?
      end
      @session.loop(15, &block)

    end

    def save
      @hosts.each_value do |o|
        o.attributes=  { :lastseen => Time.now }
        o.save
      end
    end

    def _load_sshdata(host)
      o = SshData.first_or_new({:hostname => host})
      o.firstseen.nil? && o.attributes= { :firstseen => Time.now }
      o.lastseen.nil? && o.attributes=  { :lastseen => Time.now }
      @hosts["#{host}"] = o

    end

    def _define_execs
      @session.exec 'chef-client --version' do |ch, stream, data|
        puts "[#{ch[:host]} : #{stream}] #{data}"
        begin
          _parse_chef_client ch[:host], data
        rescue => e
          puts "------#{e.message}"
        end
      end

      @session.exec 'cat /etc/lsb-release' do |ch, stream, data|
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
