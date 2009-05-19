
class User

  # tracker concern

  def reset_passkey
    self.passkey = CryptUtils.md5_token self.username
  end

  def reset_passkey!
    reset_passkey
    save
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

    def calculate_ratio
      self.downloaded != 0 ? (self.uploaded / self.downloaded.to_f) : 0
    end
end