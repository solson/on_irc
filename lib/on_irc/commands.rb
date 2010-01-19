class IRC
  module Commands
    def privmsg(target, message)
      send_cmd(:privmsg, target, message)
    end

    alias msg privmsg

    def notice(target, message)
      send_cmd(:notice, target, message)
    end

    def join(channel)
      send_cmd(:join, channel)
    end

    def part(channel, message=nil)
      send_cmd(:part, channel, message)
    end

    def pong(msg)
      send_cmd(:pong, msg)
    end
  end
end
