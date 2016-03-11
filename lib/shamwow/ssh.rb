require 'net/ssh/multi'
require 'shamwow/db'
require 'net/ssh/gateway'


module Shamwow
  class Ssh

    def initialize

      @hosts = { }
      @debug = 1
    end

    def create_session
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

      @session.concurrent_connections = 10
      #@session.via 'vmbuilder1.sea1.marchex.com', 'jcarter'
    end

    def add_host(host)
      # get persistant object
      _load_sshdata host
      # setup ssh session
      @session.use "jcarter@#{host}", :timeout => 30
    end

    def count_hosts
      @session.servers.count
    end

    def execute
      _define_execs
      lasttick = Time.now - 60
      block = Proc.new do |c|
        if Time.now > lasttick
          lasttick = Time.now + 60
          puts "--#{Time.now}--Open connections: #{c.open_connections}"
        end
        c.busy?
      end
      @session.loop(15, &block)

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
          unless data.match(/^\s*$/) || data.match(/^ffi/)

          puts "[#{ch[:host]} : #{stream}] #{data}"
          begin
            _parse_chef_client ch[:host], data
          rescue => e
            #puts "------#{e.message}"
          end
        end
      end

      @session.exec 'cat /etc/lsb-release' do |ch, stream, data|
        unless data.match /^\s*$/
          begin
            _parse_lsb_release ch[:host], data
          rescue => e
            #puts "------#{e.message}"
          end
        end
      end

    end

    def _parse_chef_client(host, data)
      ver = (data.split " ")[1].strip
      _save_ssh_data(host, { :chefver => ver, :chefver_polltime => Time.now })
    end


    def _parse_lsb_release(host, data)
      ver = data.match(/DISTRIB_DESCRIPTION=(.*)/)[1]
      ver = ver.strip().gsub! /"/, ''
      _save_ssh_data(host, { :os => ver, :os_polltime => Time.now })

    end

    def _save_ssh_data(host, attributes)
      o = @hosts["#{host}"]
      o.attributes = attributes
      o.save
    end
  end
end
