require 'net/ssh/multi'
require 'shamwow/db'
require 'net/ssh/gateway'


module Shamwow
  class Ssh

    def initialize
      @errors = []
      @errortypes = {}
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
          _save_error server.to_s, 'create_session', $ERROR_INFO
          throw :go
        end
      end
      @session = Net::SSH::Multi::Session.new
      @session.on_error = handler

      @session.concurrent_connections = 50
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
          puts "#{Time.now}--Open connections: #{c.open_connections}"
        end
        c.busy?
      end
      @session.loop(15, &block)

    end

    def save
      @hosts.each_value do |o|
        o.save
      end

      @errortypes.each do |type, count|
        puts "Error type: #{type}: #{count}"
      end
    end

    def _load_sshdata(host)
      o = SshData.first_or_new({:hostname => host})
      @hosts["#{host}"] = o

    end

    def _define_execs
      @session.exec 'chef-client --version' do |ch, stream, data|
          unless data.match(/^\s*$/) || data.match(/^ffi/)

          begin
            _parse_chef_client ch[:host], data
          rescue => e
            #puts "------#{e.message}"
          end
        end
      end

      # @session.exec 'cat /etc/lsb-release' do |ch, stream, data|
      #   unless data.match(/^\s*$/) || stream.match(/stderr/)
      #     begin
      #       _parse_lsb_release ch[:host], data
      #     rescue => e
      #       #puts "------#{e.message}"
      #     end
      #   end
      # end
      #
      # @session.exec 'cat /etc/redhat-release'  do |ch, stream, data|
      #   unless stream.match(/stderr/)
      #     puts "[#{ch[:host]} : #{stream}] #{data}"
      #     begin
      #       _parse_redhat_release ch[:host], data
      #     rescue => e
      #       puts "------#{e.message}"
      #     end
      #   end
      # end

      @session.exec 'cat /etc/issue'  do |ch, stream, data|
        unless stream.match(/stderr/)
          begin
            _parse_issue ch[:host], data
          rescue => e
            puts "------#{e.message}"
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
      ver = ver.gsub(/"/, '').strip
      _save_ssh_data(host, { :os => ver, :os_polltime => Time.now })
    end

    def _parse_redhat_release(host, data)
      _save_ssh_data(host, { :os => data, :os_polltime => Time.now })
    end

    def _parse_issue(host, data)
      ver = data.gsub(/(\\\w)/, '').gsub(/^Kernel.*$/,'').strip
      _save_ssh_data(host, { :os => ver, :os_polltime => Time.now })
    end

    def _save_ssh_data(host, attributes)
      o = @hosts["#{host}"]
      o.attributes = attributes
      o.save
    end

    def _save_error(host, action, message)
      o = ErrorData.new
      o.attributes= {
          :timestamp => Time.now,
          :hostname => host,
          :action => action,
          :message => message
      }
      o.save
      @errors.push(o)
      @errortypes["#{message}"] ||= 0
      @errortypes["#{message}"] += 1
    end
  end
end
