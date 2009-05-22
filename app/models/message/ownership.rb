
class Message

  # ownership concern

  class NotOwnerError < StandardError
  end

  def owned_by?(user)
    self.owner_id == user.id
  end

  def ensure_ownership(user)
    raise NotOwnerError unless owned_by? user
  end
end
