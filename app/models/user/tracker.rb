
class User

  # tracker concern

  def reset_passkey
    self.passkey = CryptUtils.md5_token self.username
  end

  def reset_passkey!
    reset_passkey
    save
  end

  def ratio
    if self.downloaded != 0
      self.uploaded / self.downloaded.to_f
    else
      0
    end
  end

  def update_counters(up_offset, down_offset)
    User.transaction do
      lock!
      self.uploaded += up_offset
      self.downloaded += down_offset
      save
    end
  end
end