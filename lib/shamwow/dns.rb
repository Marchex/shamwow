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
      p Net::DNS::Resolver.start(domain, Net::DNS::AXFR)
    end
  end
end
