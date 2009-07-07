module IRC  
  class ConfigError < StandardError; end

  Config = Struct.new(:nick, :ident, :realname, :servers)

  class ConfigDSL
    dsl_accessor :nick, :ident, :realname
    attr_accessor :servers
    
    def self.run(&block)
      confdsl = self.new
      block.arity < 1 ? confdsl.instance_eval(&block) : block.call(confdsl)
      
      raise ConfigError, 'no nick' unless confdsl.nick
      raise ConfigError, 'no servers' unless confdsl.servers
      
      conf = Config.new
      
      conf.nick = confdsl.nick
      conf.ident = confdsl.ident || confdsl.nick
      conf.realname = confdsl.realname || confdsl.nick
      conf.servers = confdsl.servers
      
      conf
    end
    
    def server(id, &block)
      @servers ||= {}
      @servers[id] = Server.new Server::ConfigDSL.run(&block)
      @servers[id]
    end
  end
end

