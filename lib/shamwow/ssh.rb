require 'net/ssh/multi'
require 'shamwow/db'
#Dir["shamwow/ssh/*.rb"].each {|file| require file; puts "#{file}" }
require 'shamwow/ssh/chef_version'
require 'shamwow/ssh/etc_issue'
require 'shamwow/ssh/chef_stacktrace'
require 'shamwow/ssh/chef_whyrun'


module Shamwow
  class Ssh

    def initialize
      @errors = []
      @errortypes = {}
      @taskcounts = {}
      @hosts = { }
      @debug = 1
      @tasks = {}
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
      #_define_execs
      load_tasks
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

      @taskcounts.each do |type, count|
        puts "Task type: #{type}: #{count}"
      end
      @errortypes.each do |type, count|
        puts "Error type: #{type}: #{count}"
      end
    end

    def _load_sshdata(host)
      o = SshData.first_or_new({:hostname => host})
      @hosts["#{host}"] = o
    end

    def load_tasks
      tasks = SshTask.constants.select {|c| SshTask.const_get(c).is_a? Class}
      tasks.each do |task|
        @session.open_channel do |channel|
          channel.request_pty do |c, success|
            result = String.new
            raise "could not request pty" unless success
            #
            channel.exec SshTask.const_get(task).command
            #
            channel.on_data do |c_, data|
              host = channel[:host]
              if data =~ /\[sudo\]/ || data =~ /Password/i
                channel.send_data "PASSWORD\n"
              else
                result = result.concat data
              end
            end
            #
            channel.on_close do |c_, data|
              #puts Time.now.to_s.concat "--PARSING--#{c_[:host]}--".concat task.to_s
              attributes = SshTask.const_get(task).parse(result)
              SshTask.const_get(task).save(@hosts, channel[:host], attributes)
              @taskcounts[task] ||=0
              @taskcounts[task] += 1
            end
          end
        end
      end
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
