#!/usr/bin/env ruby
require 'bundler/setup'
require 'rubygems'
require 'shamwow/db'

module Shamwow
  db = Shamwow::Db.new('postgres://shamwow:shamwow@bumper.sea.marchex.com/shamwow', true)
  db.bootstrap_db
  patterns = {}
  products = Products.all

  sshhosts = SshData.all

  products.each do |product|
    p_array = product[:host_groups].split

    p_array.each do |p|
      patterns["#{p}"] = product[:product_group]
    end
  end
  puts patterns.count
  sshhosts.each do |sshhost|
    begin
    host = Host.first_or_create({ :hostname => sshhost[:hostname]})
    rescue
      db.save_error(sshhost[:hostname], 'categorize_hosts::create_host', sshhost)

    end

    name = host[:hostname]
    host[:ssh_lastseen] = sshhost[:chefver_polltime]
    case
      when name.match(/devint/) || name.match(/^di\-/)
        host[:environment] = 'dev-int'
      when name.match(/^qa[\d]{0,1}\-/) || name.match(/\.qa[\d]{0,1}\./) || name.match(/^qa/) || name.match(/\-qa\./)
        host[:environment] = 'qa'
      when name.match(/^stg\-/) || name.match(/\.stg\./)
        host[:environment] = 'staging'
      when name.match(/^ci\-/)
        host[:environment] = 'cont-int'
      else
    end


    name.gsub!(/^devint\-/, '')
    name.gsub!(/^ci\-/, '')
    name.gsub!(/^stg\-/, '')
    name.gsub!(/^qa[\d]{0,1}\-/, '')
    patterns.each do |k,v|
      if name.match(/#{k}/)
        puts "#{name} #{k} #{v}"
        host[:product] = v
      end
    end
    begin
    host.save
    rescue
      db.save_error(host[:hostname], 'categorize_hosts::save', host)
    end
  end
  db.finalize
end
