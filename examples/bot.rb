#!/usr/bin/env ruby
require File.join(File.dirname(__FILE__), '..', 'lib', 'on_irc')

bot = IRC.new do
  nick 'on_irc'
  ident 'on_irc'
  realname 'on_irc Ruby IRC library'

  server :eighthbit do
    address 'irc.tenthbit.net'
  end
end


bot[:eighthbit].on '001' do
  join '#bots'
end

bot.on :privmsg do
  case params[1]
  when '!ping'
    respond "#{sender.nick}: pong"
  when /^!echo (.*)/
    respond "#{sender.nick}: #{$1}"
  when /^!join (.*)/
    join $1
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

