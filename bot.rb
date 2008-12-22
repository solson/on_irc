$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), 'lib'))
require 'irc'

irc = IRC.new do
  nick 'on_irc'
  ident 'on_irc'
  realname 'on_irc Ruby IRC library'
  
  server 'freenode' do
    address 'irc.freenode.org'
  end
end


# irc.on_001 do
#   irc.join '#on_irc'
# end
# 
# irc.on_privmsg do |e|
#   case e.message
#   when '!ping'
#     irc.msg(e.recipient, e.sender.nick + ': pong')
#   when /^!echo (.*)/
#     irc.msg(e.recipient, e.sender.nick + ': ' + $1)
#   when /^!join (.*)/
#     irc.join($1)
#   end
# end
# 
# irc.on_all_events do |e|
#   p e
# end
# 
# irc.connect

require 'pp'
pp irc