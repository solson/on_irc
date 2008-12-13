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
