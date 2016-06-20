require 'shamwow/db'
require 'shamwow/ssh'
require 'shamwow/dns'
require 'shamwow/http'
require 'shamwow/version'
require 'shamwow/knife'
require 'slop'
require 'highline/import'


module Shamwow
  testlist = {}
  hosts = {}
  $expire_time = 14400
  opts = Slop.parse do |o|
    o.on '-h', '--help' do
      puts 'HELP!'
      exit
    end
    o.string '--host', 'run on a hostname', default: nil
    o.string '--from', 'hosts from a file', default: nil
    o.bool   '--fromdb', 'hosts from hsots table', default: false
    o.string '--connection', 'postgres connection string', default: 'postgres://shamwow:shamwow@bumper.sea.marchex.com/shamwow'
    o.array '--sshtasks', 'a list of sshtasks to execute', default: ['Chef_version'], delimiter: ','
    o.string '-u', '--user', 'the user to connect to using ssh', default: ENV['USER']
    o.string '-P', '--password', 'read password from args', default: nil
    o.bool '-p', '--askpass', 'read password from stdlin', default: false
    #o.bool '--all', 'poll all known hosts'
    o.bool '--dns', 'poll dns'
    o.bool '--ssh', 'poll ssh'
    o.bool '--net', 'poll network engineerings website'
    o.bool '--knife', 'poll knife status'
    o.on '--version', 'print the version' do
      puts Slop::VERSION
      exit
    end
  end

  if opts[:askpass]
    $password = ask("Enter Password:") {|q| q.echo = false }
  end

  unless opts[:user].nil?
    $user = opts[:user]
  end

  unless opts[:password].nil?
    $password = opts[:password]
  end

  unless opts[:host].nil?
    testlist[opts[:host]] = true
  end

  unless opts[:from].nil?
    fh = File.open opts[:from], 'r'
    fh.each_line do |line|
      testlist[line.strip] = true
    end
  end

  db = Shamwow::Db.new(opts[:connection], true)
  db.bootstrap_db

  if opts[:fromdb]
    hosts = Host.all
    hosts.each do |e|
      testlist[e[:hostname]] = e[:ssh_scan]
    end
  end

  if opts.dns?
    dns = Shamwow::Dns.new(db)
    out = dns.transfer_zone('bumper.sea.marchex.com', 'marchex.com')
    dns.update_records(out)
    out = dns.transfer_zone('ns2.aws-us-west-2-vpc4.marchex.com', 'aws-us-west-2-vpc4.marchex.com')
    dns.update_records(out)
    out = dns.transfer_zone('ns1.aws-us-east-1-vpc3.marchex.com', 'aws-us-east-1-vpc3.marchex.com')
    dns.update_records(out)
    out = dns.transfer_zone('ns1.aws-us-east-1-vpc1.marchex.com', 'aws-us-east-1-vpc1.marchex.com')
    dns.update_records(out)
    out = dns.transfer_zone('ns2.aws-us-west-2-vpc2.marchex.com', 'aws-us-west-2-vpc2.marchex.com')
    dns.update_records(out)
    dns.save_records
    dns.parse_all_records
    dns.expire_records($expire_time)
  end

  if opts.ssh?
    ssh = Shamwow::Ssh.new(db)
    ssh.create_session

    testlist.each do |line, enabled|
      if enabled
        stripped = line.strip
        ssh.add_host(stripped)
      else
        o = hosts.first({:hostname => line})
        puts "skipping host: #{line} because: #{o[:notes]}"
      end
    end

    puts "#{Time.now}-session count #{ssh.count_hosts}"
    ssh.execute(opts[:sshtasks])
    ssh.save
    puts "#{Time.now} Done"
  end

  if opts.net?
    h = Shamwow::Http.new(db)
    layer1 = h.get('http://netools.sad.marchex.com/report/gni/dyn/data/01.proc-summaries/01.phy-link')
    parsed = h.parse_layer1(h.remove_header(layer1))
    puts "Layer 1 record count: #{parsed.count}"
    h.save_all_layer1
    h.expire_l1_records($expire_time)
    #
    layer2 = h.get('http://netools.sad.marchex.com/report/gni/dyn/data/01.proc-summaries/02.mac-edge')
    parsed = h.parse_layer2(h.remove_header(layer2))
    puts "Layer 2 record count: #{parsed.count}"
    h.save_all_layer2
    h.expire_l2_records($expire_time)
    #
    layer3 = h.get('http://netools.sad.marchex.com/report/gni/dyn/data/01.proc-summaries/03.arp-tabl.v2-ptr')
    parsed = h.parse_layer3(h.remove_header(layer3))
    puts "Layer 3 record count: #{parsed.count}"
    h.save_all_layer3
    h.expire_l3_records($expire_time)
    #
    snmpdata = h.get('http://bluestreak.sea.marchex.com/netools-ui/data/netdump_1460422844.json')
    h.parse_zenoss_snmp(snmpdata)
    h.expire_snmp_records($expire_time)
  end

  if opts.knife?
    k = Shamwow::Knife.new(db)
    k.load_data
    out = k.get_status('bumper.sea.marchex.com')
    k.parse_status(out)
    out = k.get_attributes('bumper.sea.marchex.com')
    k.parse_attributes(out)
    k.expire_records($expire_time)
  end

  db.finalize
end
