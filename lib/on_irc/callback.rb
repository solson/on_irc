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
      def prefix
        @event.prefix
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
      def send_cmd(cmd, *args)
        @event.server.send_cmd(cmd, *args)
      end

      def privmsg(target, message)
        send_cmd(:privmsg, target, message)
      end

      alias msg privmsg

      def respond(message)
        if params[0].start_with? '#'
          send_cmd(:privmsg, params[0], message)
        else
          send_cmd(:privmsg, prefix.split('!').first, message)
        end
      end

      def join(channel)
        send_cmd(:join, channel)
      end

      def pong(msg)
        send_cmd(:pong, msg)
      end

    end
  end
end

