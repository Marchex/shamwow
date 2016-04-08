require 'shamwow/db'
require 'net/http'

module Shamwow
  class Http
    def initialize
      @ports = []

    end

    def get_layer1
      uri = URI('http://netools.sad.marchex.com/report/gni/dyn/data/01.proc-summaries/01.phy-link')
      Net::HTTP.get(uri) # => String
    end

    def remove_header(data)
      data.gsub!(/^.+records\n/,'')
    end

    def parse_layer1(data)

      data.each_line do |line|
        next if line.match(/^\s*$/)

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
  end
end
