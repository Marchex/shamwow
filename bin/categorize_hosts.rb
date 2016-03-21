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
    patterns.each do |k,v|
      if name.match(/#{k}/)
        puts "#{name} #{k} #{v}"
        host[:product] = v
        host.save
      end
    end
  end
end
