%w[rubygems eventmachine socket strscan].each { |lib| require lib }
%w[event parser dsl_accessor config_accessor server config connection callback].each do |lib|
  require File.join(File.dirname(__FILE__), 'on_irc', lib)
end

class IRC
  attr_accessor :config, :handlers, :servers
  config_accessor :nick, :ident, :realname

  def initialize(&block)
    @config = ConfigDSL.run(&block)
    @servers = {}
    @config.servers.each do |server_id, server_conf|
      @servers[server_id] = Server.new(self, server_id, server_conf)
    end
    @handlers = {}
  end

  def on(event, &block)
    @handlers[event.to_s.downcase.to_sym] = Callback.new(block)
  end

  def [](server_id)
    servers[server_id]
  end

  def send_cmd(server_id, cmd, *args)
    servers[server_id].send_cmd(cmd, *args)
  end

  def connect
    EventMachine.run do
      servers.values.each do |server|
        server.connection = EM.connect(server.address, server.port, Connection, server)
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

