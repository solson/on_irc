class IRC
  class Event
    @@events = {}
    attr_reader :type, :raw
    
    def initialize(line)
      @attributes = []
      @raw = line
      
      if prefix = line[ /^:[^ ]+/ ] # All up to the first space if line starts with :
        line = line[prefix.length..-1] # cut the prefix off the line
        prefix = prefix[1..-1] # get rid of the beginning :
        
        # make the prefix a User if it matches; otherwise it's a server
        prefix = User.new(prefix) if prefix =~ /^[^!]+![^@]+@.*$/
      end
      
      if command = line[ /\s*[^ ]+/ ] # The next word is the command
        line = line[command.length..-1] # cut the command off the line
        command.strip! # cut off extra whitespace
        command.upcase! # we will deal with commands all uppercase
      end
      
      if end_param = line[ /\s+:.*$/ ] # grab the : param at the end if it exists
        line = line[0..-end_param.length] # cut it off the line
        end_param.lstrip! # cut whitespace off the left side
        end_param = end_param[1..-1] # cut off the :
      end
    
      params = line.scan(/[^ ]+/) # the rest of the words in the line are params
      params << end_param if end_param # the : param is just a trick to put spaces in a param
      
      
      if @@events[command] # these are set with Event.parser - defaults are in events.rb
        @type = command
        instance_exec(prefix, params, &@@events[command]) # sets up the Event's attributes
      elsif command =~ /^\d{3}$/ # IRC numerics
        attributes :sender, :recipient, :params
        @sender, @recipient, @params = prefix, params[0], params[1..-1]
        @type = command
      else
        @type = 'UNHANDLED'
      end
      
      if @type == 'UNHANDLED'
        attributes :sender, :command, :params
        @sender, @command, @params = prefix, command, params
      end
    end
    
    def attribute(*args)
      attributes(*args)
    end
    
    def attributes(*args)
      args.map!(&:to_sym) # You can specify args as strings, but we want symbols
      @attributes.push(*args)
      # defining reader methods for Event attributes. FIXME: this is very messy
      args.each do |arg|
        eval("class << self
                define_method(#{arg.to_s.inspect}) do
                  instance_variable_get(#{('@' + arg.to_s).inspect})
                end
              end")
      end
    end
    
    # Event.parser('PRIVMSG') do |sender, params|
    #   attributes :sender, :recipient, :message
    #   @sender, @recipient, @message = sender, params[0], params[1]
    # end
    # This allows: irc.on_privmsg do |sender, recipient, message|
    def self.parser(command, &blck)
      @@events[command.upcase] = blck
    end
    
    def inspect
      attrs = @attributes.map{ |i|
        "#{i}=#{instance_variable_get("@#{i}").inspect}"
      }
      "#<IRC::Event:#{@type} #{attrs.join(' ')}>"
    end
    
  end
end


module Kernel
 # Like instance_eval but allows parameters to be passed.
  def instance_exec(*args, &block)
    mname = "__instance_exec_#{Thread.current.object_id.abs}_#{object_id.abs}"
    Object.class_eval{ define_method(mname, &block) }
    begin
      ret = send(mname, *args)
    ensure
      Object.class_eval{ undef_method(mname) } rescue nil
    end
    ret
  end
end

