module IRC
  class Callback
    def initialize(block)
      @block = block
    end

    def call(event)
      CallbackDSL.run(event, @block)
    end

    class CallbackDSL
      def self.run(event, block)
        callbackdsl = self.new(event)
        block.arity < 1 ? callbackdsl.instance_eval(&block) : block.call(callbackdsl)
      end

      def initialize(event)
        @event = event
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
      def send(*args)
        if args[0].is_a?(Symbol) && args[1].is_a?(String)
          IRC.send(@event.server, *args) # now we don't have to do send(e.server, ...) all the time
        else
          IRC.send(*args)
        end
      end

      alias raw send

      def privmsg(target, message)
        send(:privmsg, target, message)
      end

      alias msg privmsg

      def join(channel)
        send(:join, channel)
      end

    end
  end
end

