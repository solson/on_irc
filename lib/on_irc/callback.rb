class IRC
  class Callback
    def initialize(block)
      @block = block
    end

    def call(irc, event)
      CallbackDSL.run(irc, event, @block)
    end

    class CallbackDSL
      def self.run(irc, event, block)
        callbackdsl = self.new(irc, event)
        block.arity < 1 ? callbackdsl.instance_eval(&block) : block.call(callbackdsl)
      end

      def initialize(irc, event)
        @event = event
        @irc = irc
      end

      # @event accessors
      def sender
        @event.sender
      end

      def command
        @event.command
      end

      def server
        @event.server
      end

      def params
        @event.params
      end

      # commands
      include Commands

      def send_cmd(cmd, *args)
        @event.server.send_cmd(cmd, *args)
      end

      def respond(message)
        if params[0].start_with? '#'
          privmsg(params[0], message)
        else
          privmsg(sender.nick, message)
        end
      end
    end
  end
end

