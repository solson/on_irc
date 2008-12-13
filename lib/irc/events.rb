require 'irc/event'

class IRC
  
  Event.parser('PRIVMSG') do |sender, params|
    attributes :sender, :recipient, :message
    @sender, @recipient, @message = sender, params[0], params[1]
  end
  Event.parser('NOTICE') do |sender, params|
    attributes :sender, :recipient, :message
    @sender, @recipient, @message = sender, params[0], params[1]
  end
  
  Event.parser('MODE') do |sender, params|
    if params[0][0,1] == '#'
      attributes :sender, :channel, :modes
      @sender, @channel, @modes = sender, params[0], params[1]
      @type = 'CHMODE'
    else
      attributes :modes
      @modes = params[1..-1].join(' ')
      @type = 'UMODE'
    end
  end
  
  Event.parser('JOIN') do |sender, params|
    attributes :sender, :channel
    @sender, @channel = sender, params[0]
  end
  Event.parser('PART') do |sender, params|
    attributes :sender, :channel, :reason
    @sender, @channel = sender, params[0], params[1]
  end
  Event.parser('TOPIC') do |sender, params|
    attributes :sender, :channel, :topic
    @sender, @channel, @topic = sender, params[0], params[1]
  end
  
  Event.parser('INVITE') do |sender, params|
    attributes :sender, :channel
    @sender, @channel = sender, params[1]
  end
  
  Event.parser('PING') do |sender, params|
    attribute :origin
    @origin = params[0]
  end  
  Event.parser('PONG') do |sender, params|
    attributes :sender, :origin
    @sender, @origin = sender, params[1]
  end

  Event.parser('QUIT') do |sender, params|
    attributes :sender, :message
    @sender, @message = sender, params[0]
  end
  
end
