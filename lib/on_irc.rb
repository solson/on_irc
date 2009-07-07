%w[rubygems eventmachine socket strscan].each { |lib| require lib }
%w[event parser dsl_accessor config_accessor server config connection].each do |lib|
  require File.join(File.dirname(__FILE__), 'on_irc', lib)
end

module IRC
  class << self
    attr_accessor :config, :handlers
    config_accessor :nick, :ident, :realname, :servers
    
    def configure(&block)
      @config = ConfigDSL.run(&block)
      @handlers = {}
    end

    def on(event, &block)
      @handlers[event.to_s.downcase.to_sym] = block
    end
    
    def [](server_id)
      servers[server_id]
    end
    
    def send(server, cmd, *args)
      cmd = cmd.to_s.upcase
      args[-1] = ':' + args[-1]
      IRC[server].connection.command(cmd, *args)
    end

    def connect
      EventMachine.run do
        servers.each do |id, server|
          server.connection = EM.connect(server.address, server.port, Connection, id)
        end
      end
    end

#   for ssl
#      require 'openssl'
#      ssl_context = OpenSSL::SSL::SSLContext.new
#      ssl_context.verify_mode = OpenSSL::SSL::VERIFY_NONE
#      @socket = OpenSSL::SSL::SSLSocket.new(socket, ssl_context)
#      @socket.sync = true
#      @socket.connect
  end
end

