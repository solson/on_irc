module IRC
  class Server
    attr_accessor :config, :connection, :handlers
    config_accessor :address, :port, :nick, :ident, :realname, :ssl
    
    def initialize(config)
      @config = config
      @handlers = {}
    end
    
    def on(event, &block)
      @handlers[event.to_s.downcase.to_sym] = block
    end
    
    Config = Struct.new(:address, :port, :nick, :ident, :realname, :ssl)
    
    class ConfigDSL
      dsl_accessor :address, :port, :nick, :ident, :realname
      bool_dsl_accessor :ssl
      
      def self.run(&block)
        confdsl = self.new
        block.arity < 1 ? confdsl.instance_eval(&block) : block.call(confdsl)
        
        raise ConfigError, 'no address' unless confdsl.address
        
        conf = Config.new
        
        conf.address = confdsl.address
        # If not supplied, the port defaults to 6667, or 6697 if ssl is used
        conf.port = confdsl.port || (confdsl.ssl? ? 6697 : 6667)
        conf.ssl = confdsl.ssl?
        conf.nick = confdsl.nick
        conf.ident = confdsl.ident
        conf.realname = confdsl.realname
        
        conf
      end
    end
  end
end
