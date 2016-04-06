require 'net/ssh'
require 'shamwow/db'


module Shamwow
  class Dns
    def initialize
      @hosts = {}
      @@errors = []
      @@errortypes = {}
    end

    def transfer_zone(domain)
      Net::SSH.start('bumper.sea.marchex.com') do |ssh|
        # capture all stderr and stdout output from a remote process
        output = ssh.exec!("dig axfr marchex.com")
        output.gsub!(/^(;.*)$/, '')
        output.gsub!(/^\n$/,'')
        output
      end
    end
    # "m1._domainkey.marchex.com. 3600	IN	TXT	"v=DKIM1\; k=rsa\; p=MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQDFUlNZvtGDlIGDRtzyRQydM9yRInD5YMx86QpgZ3v7pT+Mx4tGbjUxY41TXbsp7UH9hTREaKKGQKNM/B3FzcFVv4zafZ09lUaXcbSdtD70iXyH0OXEGXLZI5gG0ZwjK5ptgQ18d+pUP9s8xMkJnZlubTk9MLvQnv3ZBzoL9FHFDQIDAQAB"
    # "_sipfederationtls._tcp.marchex.com. 3600 IN SRV	100 1 5061 sipfed.online.lync.com."
    # "arc-landingpages.marchex.com. 3600 IN	CNAME	masclp.som1.marchex.com."
    # "*.www1.devint.marchex.com. 86400 IN	A	10.108.249.16"
    def update_records(output)
      nowtime = Time.now
      output.each_line do |l|
        next if l.match(/^\s*$/)
        puts "#{l}"
        line = l.chomp
        m = line.match(/^([\*\w\._\-]+)\s+(\d+)\s+(\w+)\s+(\w+)\s+(.*)$/)
        n = m[1].gsub!(/\.$/,'')
        o = DnsData.first_or_new({:name => n, :type => m[4] })
        i = Integer(m[2])
        o.attributes={ :ttl => i, :class => m[3], :type => m[4], :address => m[5], :polltime => nowtime }
        @hosts["#{m[4]}--#{n}"] = o
        o.save
      end
    end

    def get_records
      @hosts
    end

    def save_records
      @hosts.each_value do |o|
        o.save
      end

      @@errortypes.each do |type, count|
        puts "Error type: #{type}: #{count}"
      end
    end

    def parse_records
      all = DnsData.all
      all.each do |o|
        o.domain = o.name.match(/^[\w\-_\*]+\.(.+)$/)[1]
        n = o.name.gsub(/\.$/,'')
        o.name = n
        if o.type == 'A'
          o.classB = o.address.match(/^(\d{1,3}\.\d{1,3})[\d\.]+/)[1]
          o.classC = o.address.match(/^(\d{1,3}\.\d{1,3}\.\d{1,3})[\d\.]+/)[1]

        end
        o.save
      end
    end
  end
end

