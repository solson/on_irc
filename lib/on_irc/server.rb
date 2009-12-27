class IRC
  class Server
    attr_accessor :config, :connection, :handlers, :name, :irc
    config_accessor :address, :port, :nick, :ident, :realname, :ssl

    def initialize(irc, name, config)
      @irc = irc
      @name = name
      @config = config
      @handlers = {}
    end

    def send_cmd(cmd, *args)
      # prepend last arg with : only if it exists. it's really ugly
      args[-1] = ":#{args[-1]}" if args[-1]
      connection.send_data(cmd.to_s.upcase + ' ' + args.join(' ') + "\r\n")
    end

    def on(event, &block)
      @handlers[event.to_s.downcase.to_sym] = Callback.new(block)
    end

    def handle_event(event)
      if @handlers[:all]
        @handlers[:all].call(@irc, event)
      elsif @irc.handlers[:all]
        @irc.handlers[:all].call(@irc, event)
      end

      if @handlers[event.command]
        @handlers[event.command].call(@irc, event)
      elsif @irc.handlers[event.command]
        @irc.handlers[event.command].call(@irc, event)
      end
    end

    # Eventmachine callbacks
    def receive_line(line)
      parsed_line = Parser.parse(line)
      event = Event.new(self, parsed_line[:prefix],
                        parsed_line[:command].downcase.to_sym,
                        parsed_line[:params])
      handle_event(event)
    end

    def unbind
      EM.add_timer(3) do
        connection.reconnect(config.address, config.port)
        connection.post_init
      end
    end
  end
end
