#!/usr/bin/env ruby
require 'bundler/setup'
require 'rubygems'
require 'shamwow/db'

module Shamwow
  db = Shamwow::Db.new('postgres://jcarter@localhost/shamwow', true)
  db.bootstrap_db
  patterns = {}
  products = Products.all
  hosts = Host.all
  products.each do |product|
    p_array = product[:host_groups].split

    p_array.each do |p|
      patterns["#{p}"] = product[:product_group]
    end
  end
  puts patterns.count
  hosts.each do |host|
    name = host[:hostname]
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
    host.save
  end
end
