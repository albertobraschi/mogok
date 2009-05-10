
class User

  # tracker concern

  def announce_passkey(torrent)
    hmac = CryptUtils.hmac_md5 torrent.announce_key, self.passkey
    hmac + self.id.to_s # append user id to hmac
  end

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
      u = self.class.find self.id, :lock => true # get a fresh and locked instance
      u.uploaded += up_offset
      u.downloaded += down_offset
      u.save
    end
  end

  def self.parse_id_from_announce_passkey(passkey)
    if passkey && passkey.size > 32
      return passkey[32, passkey.size - 1]
    end
    nil
  end
end