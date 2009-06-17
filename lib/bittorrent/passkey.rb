require 'openssl'

module Bittorrent

  module Passkey

    protected

      # Make an announce passkey. It is composed by the 32 characters hmac generated from the torrent
      # announce key and the user passkey followed by the user id.
      def make_announce_passkey(torrent, user)
        hmac = OpenSSL::HMAC.hexdigest(OpenSSL::Digest::MD5.new, torrent.announce_key, user.passkey).upcase
        hmac + user.id.to_s
      end

      # Just get the user id that is in the end of the announce passkey, after the hmac.
      def parse_user_id_from_announce_passkey(passkey)
        begin
          passkey.size > 32 ? Integer(passkey[32, passkey.size - 1]) : nil
        rescue
          nil
        end
      end
  end
end