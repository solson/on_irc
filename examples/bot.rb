#!/usr/bin/env ruby
require File.join(File.dirname(__FILE__), '..', 'lib', 'on_irc')

IRC.configure do
  nick 'on_irc'
  ident 'on_irc'
  realname 'on_irc Ruby IRC library'
  
  server :eighthbit do
    address 'irc.eighthbit.net'
  end
  
  server :freenode do
    address 'irc.freenode.org'
  end
end


IRC[:freenode].on :'001' do |e|
  IRC.send(e.server, :join, '#botters')
end

IRC[:eighthbit].on :'001' do |e|
  IRC.send(e.server, :join, '#offtopic')
end

IRC.on :privmsg do |e|
  case e.params[1]
  when '!ping'
    IRC.send(e.server, :privmsg, e.params[0], e.prefix.split('!').first + ': pong')
  when /^!echo (.*)/
    s = $1
    IRC.send(e.server, :privmsg, e.params[0], e.prefix.split('!').first + ': ' + s)
  when /^!join (.*)/
    IRC.send(e.server, :join, $1)
  end
end

IRC.on :ping do |e|
  IRC.send(e.server, :pong, e.params[0])
end

IRC.on :all do |e|
  prefix = "(#{e.prefix}) " unless e.prefix.empty?
  puts "#{e.server}: #{prefix}#{e.command} #{e.params.inspect}"
end

IRC.connect

