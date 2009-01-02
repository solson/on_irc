class IRC
  class Config
    attr_accessor :nick, :ident, :realname, :servers
    
    def self.new_from_dsl(dsl)
      conf = new
      conf.nick = dsl.nick
      conf.ident = dsl.ident || dsl.nick
      conf.realname = dsl.realname || dsl.nick
      conf.servers = dsl.servers || []
      conf
    end
    
    class DSL
      dsl_accessor :nick, :ident, :realname
      
      def server(name, &blk)
        @servers ||= []
        @servers << Server.new(name, &blk)
      end
      
      def servers
        @servers
      end
    end
  end
end
