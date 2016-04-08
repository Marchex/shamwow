require 'shamwow/db'
require 'net/http'

module Shamwow
  class Http
    def initialize
      @ports = []

    end

    def get(url)
      uri = URI(url)
      Net::HTTP.get(uri) # => String
    end

    def remove_header(data)
      data.gsub!(/^.+records\n/,'')
    end

    def parse_layer1(data)

      data.each_line do |l|
        next if l.match(/^\s*$/)
        line = l.chomp
        m = nil
        m = line.match(/^([\w\-_\.]+):\s+([\w\/:\-]+|Port-channel\s\d+)\s+(\w+)\s*(.*)$/)
        p line if m.nil?
        @ports.push(m)
      end
      @ports
    end

    def save_all_layer1()
      polltime = Time.now
      @ports.each do |m|
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
        end
        @ports.push(m)
      end
      @ports
    end

    def save_all_layer2()
      polltime = Time.now
      @ports.each do |m|
        o = Layer2Data.first_or_create({:ethswitch => m[1], :interface => m[2]})
        prefix = m[3][0..5]
        o.attributes= { :macaddress => m[3], :macprefix => prefix, :vlan => m[4], :polltime => polltime }
        o.save
      end
    end
  end
end
