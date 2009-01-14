class IRC
  class Server
    class Config
      attr_accessor :address, :port, :nick, :ident, :realname, :ssl
      
      def self.new_from_dsl(dsl)
        conf = new
        conf.nick     = dsl.nick
        conf.ident    = dsl.ident || dsl.nick
        conf.realname = dsl.realname || dsl.nick
        conf.address  = dsl.address
        conf.ssl      = dsl.ssl? || false
        conf.port     = dsl.port || (conf.ssl ? 6697 : 6667) # use 6697 as default if ssl is enabled
        conf
      end
      
      class DSL
        dsl_accessor :address, :port, :nick, :ident, :realname
        
        def ssl(val=true)
          @ssl = !!val
        end
        
        def ssl?
          @ssl
        end
      end
    end
    
    attr_accessor :config, :name
    
    def initialize(name, &blk)
      dsl = Config::DSL.new
      dsl.instance_eval(&blk)
      @config = Config.new_from_dsl(dsl)
      @name = name
      
#       %w{address port nick ident realname ssl}.each do |m|
#         eval("
#           class << self
#             def #{m}
#               @config.#{m}
#             end
#           end
#         ")
      end
    end
    
  end
end