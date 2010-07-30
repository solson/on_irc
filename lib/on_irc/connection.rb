class IRC
  class Connection < EventMachine::Connection
    include EventMachine::Protocols::LineText2

    def initialize(server)
      @server = server
    end

    ## EventMachine callbacks
    def post_init
      send_data("USER #{@server.ident || @server.irc.ident} * * #{@server.realname || @server.irc.realname}\r\n")
      send_data("NICK #{@server.nick || @server.irc.nick}\r\n")
    rescue => e
      p e
    end

    def receive_line(line)
      @server.receive_line(RUBY_VERSION < "1.9" ? line : line.force_encoding('utf-8'))
    end

    def unbind
      @server.unbind
    end
  end
end

