
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

  def self.update_user_counters(user, uploaded, downloaded)
    User.transaction do
      u = find user.id, :lock => true
      u.uploaded += uploaded
      u.downloaded += downloaded
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