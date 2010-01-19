#!/usr/bin/env ruby
require File.join(File.dirname(__FILE__), '..', 'lib', 'on_irc')

bot = IRC.new do
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


bot[:freenode].on '001' do
  join '#botters'
end

bot[:eighthbit].on '001' do
  join '#offtopic'
end

bot.on :privmsg do
  case params[1]
  when /^fn> (.*)/
    bot[:freenode].msg('#botters', "<8b:#{sender.nick}> #{$1}") if params[0] == '#offtopic' && server.name == :eighthbit
  when /^8b> (.*)/
    bot[:eighthbit].msg('#offtopic', "<fn:#{sender.nick}> #{$1}") if params[0] == '#botters' && server.name == :freenode
  end
end

bot.on :ping do
  pong params[0]
end

bot.on :all do
  p = "(#{sender}) " unless sender.empty?
  puts "#{server.name}: #{p}#{command} #{params.inspect}"
end

bot.connect

