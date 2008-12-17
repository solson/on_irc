class IRC

  # Sends +line+ to the IRC connection, chomping existing line ending and adding \r\n
  def raw(line)
    @socket.print(line.chomp + "\r\n")
  end
  
  ## Messages
  
  # Sends a message to the +recipient+, which may be a user or a channel.
  def privmsg(recipient, message)
    raw "PRIVMSG #{recipient} :#{message}"
  end
  
  alias msg privmsg
  
  # Sends a notice to the +recipient+, which may be a user or a channel.
  def notice(recipient, message)
    raw "NOTICE #{recipient} :#{message}"
  end
  
  # Sends an action message.
  def action(recipient, message)
    ctcp_request(recipient, "ACTION", message)
  end
  
  # Sends an action notice. (Note that this is not supported by many (or maybe any) IRC clients.)
  def action_notice(recipient, message)
    ctcp_reply(recipient, "ACTION", message)
  end
  
  ## CTCP
  
  # Sends a CTCP request.
  def ctcp_request(recipient, ctcp, param=nil)
    request = ctcp
    request << ' ' + param if param
    privmsg(recipient, "\1#{request}\1")
  end
  
  # Sends a CTCP reply.
  def ctcp_reply(recipient, ctcp, param=nil)
    reply = ctcp
    reply << ' ' + param if param
    notice(recipient, "\1#{reply}\1")
  end
  
  
  # Join the specified +channels+.
  def join(*channels)
    raw "JOIN #{channels.join(',')}"
  end
  
  # Leave the specified +channel+, with +reason+ if it is given.
  def part(channel, reason=nil)
    channel << " :#{reason}" if reason
    raw "PART #{channel}"
  end
  
  
  
  def ping(message)
    raw "PING :#{message}"
  end
  
  def pong(message)
    raw "PONG :#{message}"
  end


  def quit(message=nil)
    if message
      raw "QUIT :#{message}"
    else
      raw "QUIT"
    end
  end
  
  def nick=(nick)
    raw "NICK :#{nick}"
  end

end
