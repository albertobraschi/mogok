
module CryptUtils
  require 'digest'
  require 'openssl'

  def self.encrypt_password(password, salt)
    Digest::SHA1.hexdigest("#{password} #{salt}").upcase
  end

  def self.sha1_digest(data)
    Digest::SHA1.digest(data)
  end

  def self.md5_token(param = '', limit = nil)
    s = Digest::MD5.hexdigest("#{param}-#{rand}").upcase
    limit ? s[0, limit] : s
  end

  def self.hmac_md5(key, data)
    OpenSSL::HMAC.hexdigest(OpenSSL::Digest::MD5.new, key, data).upcase
  end

  def self.hexencode(data)
    Digest.hexencode(data).upcase
  end
end