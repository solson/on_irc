$LOAD_PATH << './lib'
require 'irc'

$b = binding() # for !eval

irc = IRC.new do
  nick 'on_irc'
  # if ident/realname is not supplied, nick will be used for the ident/realname
  ident 'on_irc'
  realname 'on_irc Ruby IRC library'
  
  server 'freenode' do
    address 'irc.freenode.org'
    # port defaults to 6667
    
    # this server will default to the global nick/ident/realname
  end
  
  server 'ExampleNet' do
    address 'irc.example.net'
    # when we use ssl, the port defaults to 6697 instead of 6667,
    # so we don't have to put the port unless it's a non standard port
    port 6697 
    ssl

    nick 'on_irc123' # this server will use this nick, and the global ident/realname
end


irc.on_001 do
  irc.join '#on_irc'
end

irc.on_privmsg do |e|
  case e.message
  when '!ping'
    irc.msg(e.recipient, e.sender.nick + ': pong')
  when /^!echo (.*)/
    irc.msg(e.recipient, e.sender.nick + ': ' + $1)
  when /^!join (.*)/
    irc.join($1)
  end
end

irc.on_all_events do |e|
  p e
end

irc.connect
