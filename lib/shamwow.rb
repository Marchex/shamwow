require 'shamwow/db'
require 'shamwow/ssh'
require 'shamwow/version'


module Shamwow
  testlist = []
  #testlist = ['bumper.sea.marchex.com','vmbuilder1.sea1.marchex.com', 'vmbuilder2.sea1.marchex.com']

  fh = File.open 'data/hosts.txt', 'r'
  fh.each_line do |line|
    #next if line.match(/som1/)
    #next if line.match(/phl/)
    #next if line.match(/syd/)
    testlist.push(line.strip)
  end


  db = Shamwow::Db.new('postgres://shamwow:shamwow@bumper.sea.marchex.com/shamwow', true)
  db.bootstrap_db

  ssh = Shamwow::Ssh.new

  testlist.each do |line|
    stripped = line.strip
    ssh.add_host(stripped)
  end

  puts "session count #{ssh.count_hosts}"

  ssh.execute
  ssh.save

end
