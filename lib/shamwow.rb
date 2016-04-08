require 'shamwow/db'
require 'shamwow/ssh'
require 'shamwow/dns'
require 'shamwow/http'
require 'shamwow/version'
require 'slop'
require 'highline/import'


module Shamwow
  testlist = []

  opts = Slop.parse do |o|
    o.on '-h', '--help' do
      puts 'HELP!'
      exit
    end
    o.string '--host', 'run on a hostname', default: nil
    o.string '--from', 'hosts from a file', default: nil
    o.string '--connection', 'postgres connection string', default: 'postgres://shamwow:shamwow@bumper.sea.marchex.com/shamwow'
    o.array '--sshtasks', 'a list of sshtasks to execute', default: ['Chef_version'], delimiter: ','
    #o.string '-u', '--user', default: Process.uid
    o.string '-P', '--password', 'read password from args', default: nil
    o.bool '-p', '--askpass', 'read password from stdlin', default: false
    #o.bool '--all', 'poll all known hosts'
    o.bool '--dns', 'poll dns'
    o.bool '--ssh', 'poll ssh'
    o.bool '--net', 'poll network engineerings website'
    o.on '--version', 'print the version' do
      puts Slop::VERSION
      exit
    end
  end

  if opts[:askpass]
    $password = ask("Enter Password:") {|q| q.echo = false }
  end

  unless opts[:password].nil?
    $password = opts[:password]
  end

  unless opts[:host].nil?
    testlist.push opts[:host]
  end

  unless opts[:from].nil?
    fh = File.open opts[:from], 'r'
    fh.each_line do |line|
      testlist.push(line.strip)
    end
  end

  db = Shamwow::Db.new(opts[:connection], true)
  #db = Shamwow::Db.new('postgres://jcarter@localhost/shamwow', true)
  db.bootstrap_db

  if opts.dns?
    dns = Shamwow::Dns.new
    # out = dns.transfer_zone('marchex.com')
    # dns.update_records(out)
    # dns.save_records
    dns.parse_records

  end

  if opts.ssh?
    ssh = Shamwow::Ssh.new
    ssh.create_session

    testlist.each do |line|
      stripped = line.strip

      ssh.add_host(stripped)
    end

    puts "#{Time.now}-session count #{ssh.count_hosts}"
    ssh.execute(opts[:sshtasks])
    ssh.save
    puts "#{Time.now} Done"
  end

  if opts.net?
    h = Shamwow::Http.new
    # layer1 = h.get('http://netools.sad.marchex.com/report/gni/dyn/data/01.proc-summaries/01.phy-link')
    # parsed = h.parse_layer1(h.remove_header(layer1))
    # p parsed.count
    # h.save_all_layer1
    #layer2 = h.get('http://netools.sad.marchex.com/report/gni/dyn/data/01.proc-summaries/02.mac-edge')
    layer2 = h.get('http://netools.sad.marchex.com/report/tmp/eb/mchx.mac-address-tables.txt.edge.20160408-1244')
    parsed = h.parse_layer2(h.remove_header(layer2))
    p parsed.count
    h.save_all_layer2
    layer3 = h.get('http://netools.sad.marchex.com/report/gni/dyn/data/01.proc-summaries/03.arp-tabl.v2-ptr')
    parsed = h.parse_layer3(h.remove_header(layer3))
    p parsed.count
    h.save_all_layer3
  end

end
