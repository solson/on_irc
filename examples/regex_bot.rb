#!/usr/bin/env ruby
require File.join(File.dirname(__FILE__), '..', 'lib', 'on_irc')

MAX_BANGS = 3
CH_USER_MEMORY = {}
CHANNEL_MEMORY = {}

bot = IRC.new do
  nick 'reggie'
  ident 'reggie'
  realname 'uses on_irc Ruby IRC library'

  server :eighthbit do
    address 'irc.eighthbit.net'
  end

#  server :freenode do
#    address 'irc.freenode.org'
#  end
end

bot[:eighthbit].on :'001' do
  join '#programming'
  join '#offtopic'
end

bot.on :privmsg do
  next unless params[0][0,1] == '#' # make sure regex replace only happens in channels
  channel = params[0]
  message = params[1]

  CHANNEL_MEMORY[channel] ||= []
  CH_USER_MEMORY[channel] ||= {}
  CH_USER_MEMORY[channel][sender.nick] ||= []

  if params[1] =~ %r"^(!*)s/((?:[^\\/]|\\.)*)/((?:[^\\/]|\\.)*)/(?:(\w*))?"
    bangs   = $1
    match   = $2
    replace = $3
    flags   = $4

    if bangs.length > MAX_BANGS
      respond "#{sender.nick}: I only support up to #{MAX_BANGS} !'s."
      respond 'in bed' if rand(1000) == 42
      next
    end

    begin
      match = Regexp.new match
    rescue RegexpError => err
      respond "RegexpError: #{err.message}"
      next
    end

    target = if bangs.length == 0
      CHANNEL_MEMORY[channel][1] || ''
    else
      CH_USER_MEMORY[channel][sender.nick][-bangs.length] || ''
    end

    if flags.chars.include? 'g'
      answer = target.gsub(match, replace)
    else
      answer = target.sub(match, replace)
    end

    if bangs.length > 0 || CHANNEL_MEMORY[channel][0] == sender.nick
      respond "#{sender.nick} meant: #{answer}"
    else
      respond "#{sender.nick} thinks #{CHANNEL_MEMORY[channel][0]} meant: #{answer}"
    end

  else
    if message =~ /^\x01(\S+) (.*)\x01$/
      next unless $1 == 'ACTION'

      message = "* #{sender.nick} #{$2}"
    end

    CH_USER_MEMORY[channel][sender.nick] << message
    CH_USER_MEMORY[channel][sender.nick].unshift if CH_USER_MEMORY[channel][sender.nick].length > MAX_BANGS

    CHANNEL_MEMORY[channel] = [sender.nick, message]
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
