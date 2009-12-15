class IRC
  class Connection < EventMachine::Connection
    include EventMachine::Protocols::LineText2

    def initialize(server)
      @server = server
    end

    def config
      @server.config
    end

    def command(str)
      send_data(str + "\r\n")
    end

    ## EventMachine callbacks
    def post_init
      command "USER asdf * * :asdf"
      command "NICK asdf"
    end

    def receive_line(line)
      parsed_line = Parser.parse(line)
      event = Event.new(@server, parsed_line[:prefix], parsed_line[:command].downcase.to_sym, parsed_line[:params])

      @server.handle_event(event)
    end

    def unbind
      EM.add_timer(3) do
        reconnect(config.address, config.port)
        post_init
      end
    end
  end
end

