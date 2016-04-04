require 'shamwow/db'
require 'shamwow/ssh'
require 'shamwow/version'
require 'slop'

$password = ARGV[0]
module Shamwow
  opts = Slop.parse do |o|
    o.string '-h', '--help'
    o.string '--host', 'run on a hostname', default: 'vmbuilder1.sea1.marchex.com'
    o.bool '--all', 'poll all known hosts'
    o.bool '--dns', 'poll dns'
    o.bool '--ssh', 'poll ssh'
    o.on '--version', 'print the version' do
      puts Slop::VERSION
      exit
    end
  end



  # fh = File.open 'data/hosts.txt', 'r'
  # fh.each_line do |line|
  #   testlist.push(line.strip)
  # end

  db = Shamwow::Db.new('postgres://shamwow:shamwow@bumper.sea.marchex.com/shamwow', true)
  #db = Shamwow::Db.new('postgres://jcarter@localhost/shamwow', true)
  db.bootstrap_db

  ssh = Shamwow::Ssh.new
  ssh.create_session

  testlist.each do |line|
    stripped = line.strip

    ssh.add_host(stripped)
  end

  puts "#{Time.now}-session count #{ssh.count_hosts}"
  ssh.execute
  ssh.save
  puts "#{Time.now} Done"

end
