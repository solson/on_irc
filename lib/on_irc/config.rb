class IRC
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
      @servers[id] = ServerConfigDSL.run(&block)
      @servers[id]
    end
  end
  
  ServerConfig = Struct.new(:address, :port, :nick, :ident, :realname, :ssl)
  
  class ServerConfigDSL
    dsl_accessor :address, :port, :nick, :ident, :realname
    bool_dsl_accessor :ssl

    def self.run(&block)
      confdsl = self.new
      block.arity < 1 ? confdsl.instance_eval(&block) : block.call(confdsl)

      raise ConfigError, 'no address' unless confdsl.address

      conf = ServerConfig.new

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

