require 'net/ssh'
require 'shamwow/db'


module Shamwow
  class Dns
    def initialize(db)
      @db = db
      @hosts = {}
      @lookup = {}
      @@errors = []
      @@errortypes = {}
    end

    def transfer_zone(host, domain)
      Net::SSH.start(host, $user) do |ssh|
        # capture all stderr and stdout output from a remote process
        output = ssh.exec!("dig axfr #{domain}")
        output.gsub!(/^(;.*)$/, '')
        output.gsub!(/^\n$/,'')
        output
      end
    end

    def update_records(output)
      nowtime = Time.now
      output.each_line do |l|
        next if l.match(/^\s*$/)
        line = l.chomp
        m = line.match(/^([\*\w\._\-]+)\s+(\d+)\s+(\w+)\s+(\w+)\s+(.*)$/)
        # strip the period from the end of the name
        name = m[1].chomp('.')
        address = m[5].chomp('.')
        o = DnsData.first_or_new({:name => name, :type => m[4] })
        ttl = Integer(m[2])
        o.attributes={ :ttl => ttl, :class => m[3], :type => m[4], :address => address, :polltime => nowtime }
        @hosts["#{m[4]}--#{name}"] = o
        if o.type == 'A' || o.type == 'CNAME'
          @lookup[name] = address
        end
      end
    end

    def get_records
      @hosts
    end

    def save_records
      @hosts.each_value do |o|
        begin
          o.save
        rescue
          puts "#{Time.now}--#{o}: save_record: Exception #{$ERROR_INFO}"
        end

      end

      @@errortypes.each do |type, count|
        puts "Error type: #{type}: #{count}"
      end
    end

    def parse_all_records
      @hosts.each do |k, v|
        parse_record k,v
        v.save
      end
    end

    def parse_record(host, o)
      # get domain
      o.domain = o.name.match(/^[\w\-_\*]+\.(.+)$/)[1]
      # make sure name doesn't have an ending period
      n = o.name.gsub(/\.$/,'')
      o.name = n
      # get class B & C
      begin
        if o.type == 'A'
          o.classB = o.address.match(/^(\d{1,3}\.\d{1,3})[\d\.]+/)[1]
          o.classC = o.address.match(/^(\d{1,3}\.\d{1,3}\.\d{1,3})[\d\.]+/)[1]
          o.ipaddress = o.address
        end
        if o.type == 'CNAME'
          addr = o.address
          while !addr.match(/^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}$/)
            break if @lookup[addr].nil?
            addr = @lookup[addr]
          end
          if addr.match(/^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}$/)
            o.ipaddress = addr
            o.classB = o.ipaddress.match(/^(\d{1,3}\.\d{1,3})[\d\.]+/)[1]
            o.classC = o.ipaddress.match(/^(\d{1,3}\.\d{1,3}\.\d{1,3})[\d\.]+/)[1]
          end
        end
      rescue
        puts "#{Time.now}--#{host}: parse_record: Exception #{$ERROR_INFO}"
      end
    end

    def expire_records(expire_time)
      stale = DnsData.all(:polltime.lt => Time.at(Time.now.to_i - expire_time))
      puts "#{Time.now} Expiring #{stale.count} DNS records"
      stale.each do |n|
        @db.save_log('dns_node', n["name"], 'expire', "Expiring node from dns")
      end
      stale.destroy!
    end
  end
end

