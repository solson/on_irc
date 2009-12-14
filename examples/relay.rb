#!/usr/bin/env ruby
require 'on_irc'

IRC.configure do
  nick 'on_irc-relay'
  ident 'on_irc'
  realname 'on_irc Ruby IRC library - relay example'
  
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
  when /^fn> (.*)/
    msg = $1
    IRC.send(:freenode, :privmsg, '#botters', "<8b:#{e.prefix.split('!').first}> #{msg}") if e.params[0] == '#offtopic' && e.server == :eighthbit
  when /^8b> (.*)/
    msg = $1
    IRC.send(:eighthbit, :privmsg, '#offtopic', "<fn:#{e.prefix.split('!').first}> #{msg}") if e.params[0] == '#botters' && e.server == :freenode
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
