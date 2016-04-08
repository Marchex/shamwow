require 'shamwow/db'
require 'net/http'

module Shamwow
  class Http
    def initialize
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
        o.save
      end
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
        o.save
      end
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
        o.save
      end
    end
  end
end
