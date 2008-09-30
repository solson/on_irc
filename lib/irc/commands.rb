class IRC

	# Sends +line+ to the IRC connection.
	def raw(line)
		@socket.print(line.chomp + "\r\n")
	end
	
	## Messages
	
	# Sends a message to the +recipient+, which may be a user or a channel.
	def privmsg(recipient, message)
		self.raw "PRIVMSG #{recipient} :#{message}"
	end
	
	alias msg privmsg
	
	# Sends a notice to the +recipient+, which may be a user or a channel.
	def notice(recipient, message)
		self.raw "NOTICE #{recipient} :#{message}"
	end
	
	# Sends an action message.
	def action(recipient, message)
		self.ctcp_request(recipient, "ACTION", message)
	end
	
	# Sends an action notice. (Note that this is not supported by many IRC clients.)
	def action_notice(recipient, message)
		self.ctcp_reply(recipient, "ACTION", message)
	end
	
	## CTCP
	
	# Sends a CTCP request.
	def ctcp_request(recipient, ctcp, param=nil)
		request = ctcp
		request << ' ' + param if param
		self.privmsg(recipient, "\1#{request}\1")
	end
	
	# Sends a CTCP reply.
	def ctcp_reply(recipient, ctcp, param=nil)
		reply = ctcp
		reply << ' ' + param if param
		self.notice(recipient, "\1#{reply}\1")
	end
	
	
	# Join the specified +channel+.
	def join(channel)
		self.raw "JOIN #{channel}"
	end
	
	# Leave the specified +channel+, with +reason+ if it is given.
	def part(channel, reason=nil)
		if reason
			self.raw "PART #{channel} :#{reason}"
		else
			self.raw "PART #{channel}"
		end
	end
	
	
	
	def ping(message)
		self.raw "PING :#(message)"
	end
	
	def pong(message)
		self.raw "PONG :#{message}"
	end


  def quit(message=nil)
    if message
      self.raw "QUIT :#{message}"
    else
      self.raw "QUIT"
    end
  end

end
