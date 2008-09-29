$LOAD_PATH << './lib'
require 'irc'

$b = binding()

irc = IRC.new( :server => 'irc.freenode.org',
                 :port => 6667,
                 :nick => 'on_scott',
                :ident => 'on_irc',
             :realname => 'on_irc Ruby IRC library',
              :options => { :use_ssl => false } )

irc.on_001 do
	irc.join '#botters,##scott'
end

irc.on_privmsg do |e|
  case e.message
  when '!ping'
    irc.msg(e.recipient, e.sender.nick + ': pong')
  when /^!echo (.*)/
    irc.msg(e.recipient, e.sender.nick + ': ' + $1)
  when /^!join (.*)/
    irc.join($1)
  when '!part'
    irc.part(e.recipient)
  when '!quit'
    if e.sender.host == 'unaffiliated/sco50000'
      abort('Told to quit by ' + e.sender.mask.to_s + ' in ' + e.recipient)
    else
      irc.msg(e.recipient, e.sender.nick + ': no u')
    end
  when /^!eval (.*)/
    if e.sender.host == 'unaffiliated/sco50000'
      begin
        irc.msg(e.recipient, eval($1, $b, 'eval', 1))
      rescue Exception => error
        irc.msg(e.recipient, error.message)
      end
    else
      irc.msg(e.recipient, 'compile error')
    end
  end
end

irc.on_all_events do |e|
	p e
end

irc.connect
