require 'shamwow/db'
require 'net/http'
require 'json'

module Shamwow
  class Http
    def initialize(db)
      @db = db
      @layer1 = []
      @layer2 = []
      @layer3 = []

    end

    def get(url)
      uri = URI(url)
      Net::HTTP.get(uri) # => String
    end

    def remove_header(data)
      data.gsub!(/^.+records\n/,'') || data
    end

    def parse_layer1(data)

      data.each_line do |l|
        next if l.match(/^\s*$/)
        line = l.chomp
        m = nil
        m = line.match(/^([\w\-_\.]+):\s+([\w\/:\-]+|Port-channel\s\d+)\s+(\w+)\s*(.*)$/)
        p line if m.nil?
        @layer1.push(m)
      end
      @layer1
    end

    def save_all_layer1()
      polltime = Time.now
      @layer1.each do |m|
        o = Layer1Data.first_or_create({:ethswitch => m[1], :interface => m[2]})
        o.attributes= { :linkstate => m[3], :description => m[4], :polltime => polltime }
        begin
          o.save
        rescue
          @db.save_error("#{m[1] + m[2]}", 'Http::save_all_layer1', "#{$ERROR_INFO} #{m}")
        end

      end
    end

    def expire_l1_records(expire_time)
      stale = Layer1Data.all(:polltime.lt => Time.at(Time.now.to_i - expire_time))
      puts "#{Time.now} Expiring #{stale.count} Layer1 records"
      stale.each do |n|
        @db.save_log('layer1_node', n["ethswitch"] + '-' + n['interface'], 'expire', "Expiring node from layer1")
      end
      stale.destroy!
    end

    def parse_layer2(data)
      data.each_line do |l|
        next if l.match(/^\s*$/)
        line = l.chomp

        m = nil
        m = line.match(/^([\w\-_\.]+):\s+([\w\/:\-\,]+|Port-channel\s\d+)\s+(\w+)\s+(\w+)$/)
        if m.nil?
          p line
        else
          @layer2.push(m)
        end
      end
      @layer2
    end

    def save_all_layer2()
      polltime = Time.now
      @layer2.each do |m|
        o = Layer2Data.first_or_create({:ethswitch => m[1], :interface => m[2], :macaddress => m[3]})
        prefix = m[3][0..5]
        o.attributes= { :macprefix => prefix, :vlan => m[4], :polltime => polltime }
        begin
          o.save
        rescue
          @db.save_error("#{m[1] + m[2] + m[3]}", 'Http::save_all_layer2', "#{$ERROR_INFO} #{m}")
        end
      end
    end

    def expire_l2_records(expire_time)
      stale = Layer2Data.all(:polltime.lt => Time.at(Time.now.to_i - expire_time))
      puts "#{Time.now} Expiring #{stale.count} Layer2 records"
      stale.each do |n|
        @db.save_log('layer2_node', n["ethswitch"] + '-' + n['interface'] + '-' + n['macaddress'] + '-' + n['vlan'], 'expire', "Expiring node from layer2")
      end
      stale.destroy!
    end

    def parse_layer3(data)
      data.each_line do |l|
        next if l.match(/^\s*$/)
        line = l.chomp

        m = nil
        #admin-fw.som1.marchex.com: ge-0/0/2.0 deadbeefdb95 10.30.10.83  db-bil1qa-a-r1.som1.marchex.com
        m = line.match(/^([\w\-_\.]+):\s+([\w\/:\-\,\._]+|Port-channel\s\d+)\s+(\w+)\s+([\d\.]+)\s+([\w\.\-_]+)$/)
        if m.nil?
          p line
        else
          @layer3.push(m)
        end
      end
      @layer3
    end

    def save_all_layer3()
      polltime = Time.now
      @layer3.each do |m|
        o = Layer3Data.first_or_create({:ipgateway => m[1], :port => m[2], :macaddress => m[3], :ipaddress => m[4]})
        prefix = m[3][0..5]
        o.attributes= {  :macprefix => prefix, :rdns => m[5], :polltime => polltime }
        begin
          o.save
        rescue
          @db.save_error(m[4], 'Http::save_all_layer3', "#{$ERROR_INFO} #{m}")
        end
      end
    end

    def expire_l3_records(expire_time)
      stale = Layer3Data.all(:polltime.lt => Time.at(Time.now.to_i - expire_time))
      puts "#{Time.now} Expiring #{stale.count} Layer3 records"
      stale.each do |n|
        @db.save_log('layer3_node', n["ipgateway"] + '-' + n['port'] + '-' + n['macaddress'] + '-' + n['ipaddress'], 'expire', "Expiring node from layer3")
      end
      stale.destroy!
    end

    def parse_zenoss_snmp(text)
      nowtime = Time.now
      data = JSON.parse(text)
      data["nodes"].each do |n|
        o = SnmpNodeData.first_or_create( { :hostname => n["hostname"]})

        o.attributes={ :snmp_loc  => n["snmp_loc"],
                       :ip        => n["ip"],
                       :os_model  => n["os_model"],
                       :snmp_desc => n["snmp_desc"],
                       :serial    => n["serial"],
                       :snmp_name => n["snmp_name"],
                       :hw_make   => n["hw_make"],
                       :os_make   => n["os_make"],
                       :hw_model  => n["hw_model"],
                       :polltime  => nowtime
        }
        begin
          o.save
        rescue
          @db.save_error(n["hostname"], 'Http::parse_zenoss_snmp', "#{$ERROR_INFO} #{n}")
        end

        ifaces = n["ifaces"]
        ifaces.each do |k,v|
          oi = o.snmp_node_iface.first_or_new({ :ifacename => k })
          oi.attributes= {
              #:SnmpNodeData_id => o.id,
              :macaddr => v["macaddr"],
              :description => v["description"],
              :speed => v["speed"],
              :ipaddr => v["ipaddr"],
              :state => v["state"],
              :admin_state => v["admin_state"],
              :type => v["type"],
              :polltime => nowtime
          }
          #o.SnmpNodeIface << oi
          begin
            oi.save
          rescue
            @db.save_error(n["hostname"], 'Http::parse_zenoss_snmp', "#{$ERROR_INFO} #{v}")
          end
        end
        o.save
      end
    end

    def expire_snmp_records(expire_time)
      SnmpNodeIface.all(:polltime.lt => Time.at(Time.now.to_i - expire_time)).destroy
      SnmpNodeData.all(:polltime.lt => Time.at(Time.now.to_i - expire_time)).destroy
    end
  end
end

