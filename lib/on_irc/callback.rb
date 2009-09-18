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
    end
  end
end

