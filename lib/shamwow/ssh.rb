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

      @session.exec 'cat /etc/issue'  do |ch, stream, data|
        unless stream.match(/stderr/)
          begin
            _parse_issue ch[:host], data
          rescue => e
            #puts "------#{e.message}"
          end
        end
      end

      @session.open_channel do |channel|
        channel.request_pty do |c, success|
          result = String.new
          raise "could not request pty" unless success

          channel.exec "sudo cat /var/chef/cache/chef-stacktrace.out"
          channel.on_data do |c_, data|
            host = channel[:host]
            if data =~ /\[sudo\]/ || data =~ /Password/i
              channel.send_data "PASSWORD\n"
            else
              result = result.concat data
            end
          end
          channel.on_close do |c_, data|
            attributes = _parse_strace(result)
            _save_ssh_data(channel[:host], attributes)

          end
        end
      end
    end

    def _parse_chef_client(host, data)
      ver = (data.split " ")[1].strip
      _save_ssh_data(host, { :chefver => ver, :chefver_polltime => Time.now })
    end

    def _parse_issue(host, data)
      ver = data.gsub(/(\\\w)/, '').gsub(/^Kernel.*$/,'').strip
      _save_ssh_data(host, { :os => ver, :os_polltime => Time.now })
    end

    def _parse_strace(data)
      begin
        gentime = data.match(/Generated at (\d\d\d\d-\d\d-\d\d \d\d:\d\d:\d\d\s+[\+-]\d+)/)[1]
      rescue
      end
      begin
        method  = data.match(/^([^G\/].+)$/)[1].strip
      rescue
      end
      {
          :chef_strace_method => method,
          :chef_strace_gentime => gentime.nil? ? nil : Time.parse(gentime),
          :chef_strace_full => data,
          :chef_strace_polltime => Time.now
      }
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
