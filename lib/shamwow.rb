require 'shamwow/db'
require 'shamwow/ssh'
require 'shamwow/version'


module Shamwow
  testlist = []
  #testlist = ['bumper.sea.marchex.com','vmbuilder1.sea1.marchex.com', 'vmbuilder2.sea1.marchex.com']
  #testlist = ['cxcache4.sea1.marchex.com']
  fh = File.open 'data/cx-hosts.out', 'r'
  fh.each_line do |line|
    #next if line.match(/som1/)
    #next if line.match(/phl/)
    #next if line.match(/syd/)
    testlist.push(line.strip)
  end


  #db = Shamwow::Db.new('postgres://shamwow:shamwow@bumper.sea.marchex.com/shamwow', true)
  db = Shamwow::Db.new('postgres://jcarter@localhost/shamwow', true)
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
