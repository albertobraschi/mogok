
# technoweenie's concerns pattern (http://pastie.org/pastes/200292)
	# usage:
    # app/models/user.rb
    #   class User < ActiveRecord::Base
    #     concerns :authentication, ...
    #   end

    # app/models/user/authentication.rb
    #   class User
    #     def authenticate(username, password)
    #       ...
    #     end
    #   end
  class << ActiveRecord::Base
    def concerns(*args)
      args.each do |concern|
        require_dependency "#{name.underscore}/#{concern}"
      end
    end
  end




