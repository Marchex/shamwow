#!/usr/bin/env ruby
require 'bundler/setup'
require 'rubygems'
require 'shamwow/db'
require 'shamwow/ssh'

# You can add fixtures and/or initialization code here to make experimenting
# with your gem easier. You can also use a different console, if you like.

# (If you use this, don't forget to add pry to your Gemfile!)
# require "pry"
# Pry.start
db = Shamwow::Db.new('postgres://REDACTED@REDACTED/REDACTED', true)
puts "sup"
ssh = Shamwow::Ssh.new

record = Shamwow::SshData.first(:hostname => 'REDACTED')

#data.each do |record|

  attributes = ssh._parse_strace(record[:chef_strace_full])
  if attributes[:chef_strace_method].nil?
    puts record[:hostname]
  end
#end
