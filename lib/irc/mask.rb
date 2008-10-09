class IRC
  class Mask
    attr_reader :nick, :ident, :host
  
    def initialize(mask)
      @mask = mask
      @nick, @ident, @host = /^([^!]+)!([^@]+)@(.+)$/.match(@mask).captures
    end
    
    def ==(other)
      @mask == other.to_s
    end
    
    def to_s
      @mask
    end
    
    def inspect
      "\"#@mask\""
    end
  end
end
