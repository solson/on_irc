module IRC
  class Connection < EventMachine::Connection
    include EventMachine::Protocols::LineText2
    
    def initialize(server_id)
      @server = server_id
    end
    
    def config
      IRC[@server].config
    end
    
    def command(*cmd)
      send_data(cmd.join(' ') + "\r\n")
    end
    
    def handle_event(event)
      if IRC[@server].handlers[:all]
        IRC[@server].handlers[:all].call(event)
      elsif IRC.handlers[:all]
        IRC.handlers[:all].call(event)
      end
      
      if IRC[@server].handlers[event.command]
        IRC[@server].handlers[event.command].call(event)
      elsif IRC.handlers[event.command]
        IRC.handlers[event.command].call(event)
      end
    end
    
    ## EventMachine callbacks
    def post_init
      command "USER #{config.ident || IRC.config.ident} * * :#{config.realname || IRC.config.realname}"
      command "NICK #{config.nick || IRC.config.nick}"
    end
    
    def receive_line(line)
      parsed_line = Parser.parse(line)
      event = Event.new(@server, parsed_line[:prefix], parsed_line[:command].downcase.to_sym, parsed_line[:params])
      
      handle_event(event)
    end
    
    def unbind
      EM.add_timer(3) do
        reconnect(config.address, config.port)
        post_init
      end
    end
  end
end

