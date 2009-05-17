
module CryptUtils
  require 'digest'
  require 'openssl'

  def self.sha1_digest(data)
    Digest::SHA1.digest(data)
  end

  def self.md5_token(param = '', limit = nil)
    s = Digest::MD5.hexdigest("#{param}-#{rand}").upcase
    limit ? s[0, limit] : s
  end

  def self.hexencode(data)
    Digest.hexencode(data).upcase
  end
end