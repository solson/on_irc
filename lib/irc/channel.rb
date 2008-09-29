require 'irc/user'

class IRC
	class Channel
		def users
			{'user' => User.new}
		end
		
		def topic
		end
		
		def modes
		end
	end
end
