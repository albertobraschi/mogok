
class User

  # signup concern

  def self.make_invite_code
    CryptUtils.md5_token '', 20
  end

  def save_new_with_invite(code, invite_required)
    # note: new user may have an invite even if it is not required
    i = Invitation.find_by_code code
    unless i
      if invite_required
        add_error :invite_code, 'invalid'
        return false
      end
    else
      self.inviter_id = i.user_id
      logger.debug ":-) inviter id: #{self.inviter_id}"
    end
    if save
      logger.debug ":-) user created. id: #{self.id}"
      i.destroy if i
      return true
    end
    false
  end
end












