#!/usr/bin/env ruby
require File.join(File.dirname(__FILE__), '..', 'lib', 'on_irc')

# This implements an array that won't grow larger than a given length.
# it drops items from the start when you append to it.
class Backlog
  attr_reader :length

  def initialize(length)
    @array = []
    @length = length
  end

  def <<(msg)
    @array.unshift msg
    @array.pop if @array.length > @length

    self
  end

  def [](index)
    raise 'index out of bounds' if index >= @length
    @array[index]
  end

  def []=(index, value)
    raise 'index out of bounds' if index >= @length
    @array[index] = value
  end

  def newest
    @array.first
  end

  def oldest
    @array.last
  end
end

MAX_BANGS = 3
CH_USER_MEMORY = {}
CHANNEL_MEMORY = {}

IRC.configure do
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

IRC[:eighthbit].on :'001' do
  join '#programming'
  join '#offtopic'
end

IRC.on :privmsg do
  next unless params[0][0,1] == '#' # make sure regex replace only happens in channels
  channel = params[0]
  user = prefix.split('!').first
  message = params[1]

  if params[1] =~ %r"^(!{0,#{MAX_BANGS}})s/((?:[^\\/]|\\.)*)/((?:[^\\/]|\\.)*)/(?:(\w*))?"
    bangs   = $1
    match   = $2
    replace = $3
    flags   = $4

    begin
      match = Regexp.new match
    rescue RegexpError => err
      privmsg(params[0], 'RegexpError: ' + err.message)
      next
    end

    target = case bangs.length
    when 0
      CHANNEL_MEMORY[channel][1] || ''
    when 1..MAX_BANGS
      CH_USER_MEMORY[channel][user][bangs.length-1] || ''
    end

    if flags.chars.include? 'g'
      answer = target.gsub(match, replace)
    else
      answer = target.sub(match, replace)
    end

    if bangs.length > 0 || CHANNEL_MEMORY[channel][0] == prefix.split('!').first
      privmsg(params[0], prefix.split('!').first + ' meant: ' + answer)
    else
      privmsg(params[0], prefix.split('!').first + ' thinks ' + CHANNEL_MEMORY[channel][0] + ' meant: ' + answer)
    end

  else
    CH_USER_MEMORY[channel] ||= {}
    CH_USER_MEMORY[channel][user] ||= Backlog.new(MAX_BANGS)
    CH_USER_MEMORY[channel][user] << message
    CHANNEL_MEMORY[channel] = [user, message]
  end
end

IRC.on :ping do
  pong params[0]
end

IRC.on :all do
  prefix_str = "(#{prefix}) " unless prefix.empty?
  puts "#{server}: #{prefix_str}#{command} #{params.inspect}"
end

IRC.connect

