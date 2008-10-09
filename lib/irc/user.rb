require 'irc/mask'

class IRC
	class User
		attr_reader :mask
	
		def initialize(mask)
			@mask = Mask.new(mask)
		end
		
		def nick
			@mask.nick
		end
		
		def ident
			@mask.ident
		end
		
		def host
			@mask.host
		end
		
		def is_user?
			true
		end
		
	end
end

class String
	# We can use this in event handlers:
	#   irc.on_notice do |e|
	#     if e.sender.is_user?
	#       puts 'Recieved a notice!'
	#     else
	#       puts 'Recieved a server notice!'
	#     end
	#   end
	def is_user?
		false
	end
end
require 'irc/mask'

class IRC
  class User
    attr_reader :mask
  
    def initialize(mask)
      @mask = Mask.new(mask)
    end
    
    def nick
      @mask.nick
    end
    
    def ident
      @mask.ident
    end
    
    def host
      @mask.host
    end
    
    def is_user?
      true
    end
    
  end
end

class String
  # We can use this in event handlers:
  #   irc.on_notice do |e|
  #     if e.sender.is_user?
  #       puts 'Recieved a notice!'
  #     else
  #       puts 'Recieved a server notice!'
  #     end
  #   end
  def is_user?
    false
  end
end
