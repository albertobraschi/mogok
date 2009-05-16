
class User
  include Authentication
  include Authentication::ByPassword
  include Authentication::ByCookieToken # restful_authenticaton plugin
  
  # authentication concern

  attr_accessor :password_confirmation  

  def self.authenticate(username, password)
    u = find_by_username username
    if u && u.authenticated?(password)
      return u
    end
    nil
  end
  
  def reset_session_token!
    update_attribute :session_token, self.class.make_token
  end

  def clear_session_token!
    update_attribute :session_token, nil
  end

  def valid_session_token?(param)
    self.session_token && self.session_token == param
  end
end












