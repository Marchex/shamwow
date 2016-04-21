require 'net/ssh'
require 'shamwow/db'
require 'json'


module Shamwow
  class Knife
    def initialize
      @nodes = {}
      @@errors = []
      @@errortypes = {}
    end

    def get_knife_status(fromhost)
      Net::SSH.start(fromhost) do |ssh|
        # capture all stderr and stdout output from a remote process
        output = ssh.exec!("knife status -F json 'fqdn:*'")
        output.gsub!(/^(;.*)$/, '')
        output.gsub!(/^\n$/,'')
        output
      end
    end

    def parse_json(output)
      nowtime = Time.now
      data = JSON.parse(output)
      data.each do |n|
        #p n
        o = KnifeData.first_or_new( { :name => n["name"] })

        o.attributes={ :chefenv => n["chef_environment"],
                       :ip => n["ip"],
                       :ohai_time => Time.at(n["ohai_time"]).to_datetime,
                       :platform => n["platform"],
                       :platform_version => n["platform_version"],
                       :polltime => nowtime }
        @nodes["#{n[:name]}"] = o
        o.save
      end
    end

    def get_records
      nodes
    end

    def save_records
      nodes.each_value do |o|
        o.save
      end

      @@errortypes.each do |type, count|
        puts "Error type: #{type}: #{count}"
      end
    end

    def expire_records(expire_time)
      stale = KnifeData.all(:polltime.lt => Time.at(Time.now.to_i - expire_time))
      puts "#{Time.now} Expiring #{stale.count} Knife status records"
      stale.destroy
    end
  end
end

