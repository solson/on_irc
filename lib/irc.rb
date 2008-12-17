require 'socket'
require 'irc/configdslhelper'
require 'irc/commands'
require 'irc/mask'
require 'irc/user'
require 'irc/channel'
require 'irc/event'
require 'irc/events'
require 'irc/server'

class IRC
  class Config
    attr_accessor :nick, :ident, :realname
    
    def self.new_from_dsl(dsl)
      conf = new
      conf.nick = dsl.nick
      conf.ident = dsl.ident || dsl.nick
      conf.realname = dsl.realname || dsl.nick
      conf
    end
    
    class DSL
      dsl_accessor :nick, :ident, :realname
      
      def server(name, &blk)
        Server.new(&blk)
      end
    end
  end
  
  attr_reader :servers, :config
  
  def initialize(&blk)
    dsl = Config::DSL.new
    dsl.instance_eval(&blk)
    @config = Config.new_from_dsl(dsl)
  end
  
  #       @server   = args[:server]
  #       @port     = args[:port]     || 6667
  #       @nick     = args[:nick]
  #       @ident    = args[:ident]    || args[:nick]
  #       @realname = args[:realname] || args[:nick]
  #       @options  = args[:options]  || {}
  #       @channels = {}
  #       @handlers = {}
  #       @internal_handlers = { 'NICK' => proc{|e| @nick = e.nick if e.sender.nick == e.nick},
  #                              'PING' => proc{|e| pong(e.origin)} }
  
  # for all the irc.on_<event> magic
  def method_missing(m, *args, &blck)
    raise NoMethodError, "undefined method '#{m}' for #{self}" unless event = /^on_(.*)/.match(m.to_s)
    raise ArgumentError, "no block given" unless block_given?
    raise ArgumentError, "wrong number of arguments (#{args.length} for 0)" if args.length > 0
    
    event = event.captures[0].upcase
    @handlers[event] = blck
  end
  
  def handle_event(e)
    @handlers['ALL_EVENTS'].call(e) if @handlers['ALL_EVENTS']
    @handlers[e.type].call(e) if @handlers[e.type]
  end

  def connect
    raise "Already connected" if @running
    #Thread.new do
      # creating the socket
      socket = TCPSocket.open(@server, @port)
      if @options[:use_ssl] # using SSL
        require 'openssl'
        ssl_context = OpenSSL::SSL::SSLContext.new()
        ssl_context.verify_mode = OpenSSL::SSL::VERIFY_NONE
        @socket = OpenSSL::SSL::SSLSocket.new(socket, ssl_context)
        @socket.sync = true
        @socket.connect
      else # not using SSL
        @socket = socket
      end
      
      raw "USER #{@ident} * * :#{@realname}"
      raw "NICK #{@nick}"

      @running = true
      event_loop
    #end
  end


  def event_loop
    while @running
      begin
        handle_event Event.new(@socket.readline.chomp)
      rescue Errno::ECONNRESET, EOFError
        # Catches connection reset by peer, attempts to reconnect
        # reconnects after 5 seconds
        @socket.close
        @running = false
        sleep 5
        connect
      end
    end
  end

  private :event_loop

end

