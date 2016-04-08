require 'shamwow/db'
require 'net/http'

module Shamwow
  class Http
    def initalize

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
        m = nil
        m = line.match(/^([\w\-_\.]+):\s+(\w+)\s+(\w+)\s+(.+)$/)
        p m
      end
    end
  end
end
