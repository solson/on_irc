#!/usr/bin/env ruby
require File.join(File.dirname(__FILE__), '..', 'lib', 'on_irc')

# This implements an array that won't grow larger than a given length.
# it drops items from the start when you append to it.
class Backlog
  attr_reader :length

  def initialize(length)
    @array = []
    self.length = length
  end

  def length=(length)
    raise 'negative length' if length < 0

    @length = length

    if @array.length > @length
      @array.pop until @array.length == @length
    elsif @array.length < @length
      @array << nil until @array.length == @length
    end
  end

  def <<(msg)
    @array.unshift msg
    @array.pop if @array.length > @length
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
#TEST_STRING = 'The quick brown fox jumped over the lazy dog.'
CH_USER_MEMORY = Hash.new(Hash.new(Backlog.new(MAX_BANGS))) # Hash of Hashes of Backlogs {channel => {user => [history, of, messages]}}
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

IRC[:eighthbit].on :'001' do |e|
  IRC.send(e.server, :join, '#programming')
  IRC.send(e.server, :join, '#offtopic')
#  IRC.send(e.server, :privmsg, '#programming', "test string: #{TEST_STRING}")
end

IRC.on :privmsg do |e|
  next unless e.params[0][0,1] == '#' # only works in channels
  channel = e.params[0]
  user = e.prefix
  message = e.params[1]

  if e.params[1] =~ %r"^(!{0,#{MAX_BANGS}})s/((?:[^\\/]|\\.)*)/((?:[^\\/]|\\.)*)/(?:(\w*))?"
    bangs   = $1
    match   = $2
    replace = $3
    flags   = $4

    begin
      match = Regexp.new match
    rescue RegexpError => err
      IRC.send(e.server, :privmsg, e.params[0], 'RegexpError: ' + err.message)
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

#    IRC.send(e.server, :privmsg, e.params[0], "bangs: #{bangs.size} | match: #{match.inspect} | replace: #{replace.inspect} | flags: #{flags.inspect}")
    if bangs.length > 0 || CHANNEL_MEMORY[channel][0] == e.prefix.split('!').first
      IRC.send(e.server, :privmsg, e.params[0], e.prefix.split('!').first + ' meant: ' + answer)
    else
      IRC.send(e.server, :privmsg, e.params[0], e.prefix.split('!').first + ' thinks ' + CHANNEL_MEMORY[channel][0] + ' meant: ' + answer)
    end

  else
    CH_USER_MEMORY[channel][user] << message
    CHANNEL_MEMORY[channel] = [e.prefix.split('!').first, message]
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

