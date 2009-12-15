#!/usr/bin/env ruby
require File.join(File.dirname(__FILE__), '..', 'lib', 'on_irc')

bot = IRC.new do
  nick 'on_irc'
  ident 'on_irc'
  realname 'on_irc Ruby IRC library'
  
  server :eighthbit do
    address 'irc.eighthbit.net'
  end
end


bot[:eighthbit].on '001' do
  join '#bots'
end

bot.on :privmsg do
  case params[1]
  when '!ping'
    msg(params[0], prefix.split('!').first + ': pong')
  when /^!echo (.*)/
    msg(params[0], prefix.split('!').first + ': ' + $1)
  when /^!join (.*)/
    join $1
  end
end

bot.on :ping do
  pong params[0]
end

bot.on :all do |e|
  prefix = "(#{e.prefix}) " unless e.prefix.empty?
  puts "#{e.server}: #{prefix}#{e.command} #{e.params.inspect}"
end

bot.connect

