class IRC
  class Event
    @@events = {}
    attr_reader :type, :raw
    
    def initialize(line)
      @attributes = []
      @raw = line
      
      if prefix = line[ /^:[^ ]+/ ]
        line = line[prefix.length..-1]
        prefix = prefix[1..-1]
        
        prefix = User.new(prefix) if prefix =~ /^[^!]+![^@]+@.*$/
      end
    
      if command = line[ /\s*[^ ]+/ ]
        line = line[command.length..-1]
        command.strip!
        command.upcase!
      end
      
      if end_param = line[ /\s+:.*$/ ]
        line = line[0..-end_param.length]
        end_param.lstrip!
        end_param = end_param[1..-1]
      end
    
      params = line.scan(/[^ ]+/)
      params << end_param if end_param
      
      
      if @@events[command]
        @type = command
        instance_exec(prefix, params, &@@events[command])
      elsif command =~ /^\d{3}$/
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
      args.map!(&:to_sym)
      @attributes.push(*args)
      args.each do |arg|
        eval("
          class << self
            define_method(#{arg.to_s.inspect}) { instance_variable_get(#{('@' + arg.to_s).inspect}) }
          end
        ")
      end
    end
    
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

