require 'shamwow/db'
require 'shamwow/ssh'
require 'shamwow/version'


module Shamwow
  testlist = ['bumper.sea.marchex.com','vmbuilder1.sea1.marchex.com', 'vmbuilder2.sea1.marchex.com']

  db = Shamwow::Db.new('postgres://jcarter@localhost/shamwow', true)
  #db.bootstrap_db

  ssh = Shamwow::Ssh.new

  testlist.each do |line|
    stripped = line.strip
    ssh.add_host(stripped)
  end

  puts "session count #{ssh.count_hosts}"

  ssh.execute
  ssh.save

end
