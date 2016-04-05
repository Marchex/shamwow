require 'net/dns'
require 'shamwow/db'


module Shamwow
  class Dns
    def initialize
    end

    def get_host(host)
      p Resolver(host)
    end

    def transfer_zone(domain)
      dns = Net::DNS::Resolver.new #.start(domain, Net::DNS::AXFR)
      dns.tcp_timeout = 15
      dns.search(domain, Net::DNS::AXFR)
    end
  end
end
