class IRC
  class Sender
    attr_accessor :nick, :user, :host

    def initialize(string)
      if string =~ /^([^!]+)!([^@]+)@(.+)$/
        @nick, @user, @host = $1, $2, $3
        @server = false
      else
        @host = string
        @server = true
      end
    end

    def server?
      @server
    end

    def user?
      !@server
    end

    def to_s
      @server ? @host : @nick + '!' + @user + '@' + @host
    end

    def empty?
      to_s.empty?
    end
  end
end
