require 'socket'
require 'irc/commands'
require 'irc/mask'
require 'irc/user'
require 'irc/channel'
require 'irc/event'
require 'irc/events'

class IRC
  attr_reader :server, :port, :nick, :ident, :realname, :options, :channels
  
  def initialize(args)
    # We are using the hash argument idea from Rails
    raise TypeError, 'Argument must be a hash' unless args.is_a? Hash
    
    # Converting all the args keys to symbols
    args.each_pair do |k,v|
      args.delete(k)
      args[k.to_sym] = v if k.respond_to? :to_sym
    end
    
    # Converting all the options keys to symbols
    if args[:options].is_a? Hash
      args[:options].each_pair do |k,v|
        args[:options].delete(k)
        args[:options][k.to_sym] = v if k.respond_to? :to_sym
      end
    end
    
    @server   = args[:server]
    @port     = args[:port]     || 6667
    @nick     = args[:nick]
    @ident    = args[:ident]    || args[:nick]
    @realname = args[:realname] || args[:nick]
    @options  = args[:options]  || {}
    @channels = {}
    @handlers = { 'PING' => proc{|e| pong(e.origin)} }
    
    # Argument checking
    raise ArgumentError, 'No server specified' unless @server
    raise ArgumentError, 'No nickname specified' unless @nick
    raise TypeError, ":server must be a String" unless @server.is_a? String
    raise TypeError, ":port must be a Fixnum" unless @port.is_a? Fixnum
    raise TypeError, ":nick must be a String" unless @nick.is_a? String
    raise TypeError, ":ident must be a String" unless @ident.is_a? String
    raise TypeError, ":realname must be a String" unless @realname.is_a? String
    raise TypeError, ":options must be a Hash" unless @options.is_a? Hash
  end
  
  


  def method_missing(m, *args, &blck)
    raise NoMethodError, "undefined method '#{m}' for #{self}" unless event = /^on_(.*)/.match(m.to_s)
    raise ArgumentError, "no block given" unless block_given?
    raise ArgumentError, "wrong number of arguments (#{args.length} for 0)" if args.length > 0
    
    event = event.captures[0].downcase
    case event
      when /^\d{3}$/
        @handlers[event] = blck        
      else
        @handlers[event.upcase] = blck # definitely not staying here
    end
  end
  
  def handle_event(e)
    @handlers[e.type].call(e) if @handlers[e.type]
    @handlers['ALL_EVENTS'].call(e) if @handlers['ALL_EVENTS']
  end

  def check_timers
    
  end


#  def connected?
#    @running
#  end

  def connect
    raise "Already connected" if @running
    # creating the socket
    socket = TCPSocket.open(@server, @port)
    if @options[:use_ssl]
      require 'openssl'
      ssl_context = OpenSSL::SSL::SSLContext.new()
      ssl_context.verify_mode = OpenSSL::SSL::VERIFY_NONE
      @socket = OpenSSL::SSL::SSLSocket.new(socket, ssl_context)
      @socket.sync = true
      @socket.connect
    else
      @socket = socket
    end
    
    raw "USER #{@ident} * * :#{@realname}"
    raw "NICK #{@nick}"

    @running = true
    event_loop
  end


  def event_loop
    while @running
      begin
        handle_event Event.new(@socket.readline.chomp)
        check_timers
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

