require 'shamwow/db'
require 'shamwow/ssh'
require 'shamwow/version'
$password = ARGV[0]
module Shamwow
  testlist = ['vmbuilder1.sea1.marchex.com']

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
