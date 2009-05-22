
class User

  # tracker concern

  def reset_passkey
    self.passkey = make_passkey
  end

  def reset_passkey!
    reset_passkey
    save
  end

  def reset_passkey_with_notification(resetter)
    reset_passkey!
    notify_passkey_resetting if resetter != self
    logger.debug ':-) passkey reset'
  end

  def update_counters(up_offset, down_offset)
    User.transaction do
      lock!
      self.uploaded += up_offset
      self.downloaded += down_offset
      self.ratio = calculate_ratio
      save
    end
  end

  private

    def make_passkey
      CryptUtils.md5_token self.username
    end

    def calculate_ratio
      self.downloaded != 0 ? (self.uploaded / self.downloaded.to_f) : 0
    end
end