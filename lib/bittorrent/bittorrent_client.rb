
module Bittorrent

  module BittorrentClient

    protected

      # Returns a stored Client object or, if code not found in the database, an instance of
      # Client containing the code and version received.
      def parse_client(peer_id, ban_unknown = false)
        if peer_id.size == 20
          if peer_id[0, 1] == '-' && peer_id[7, 1] == '-' # azureus style
            code = peer_id[1, 2]
            version = peer_id[3, 4]
          else # shadow style
            code = peer_id[0, 1]
            version = peer_id[1, 5].gsub('-', '')
          end
          c = Client.find_by_code code
        end
        unless c
          c = Client.new :code => code, :name => code
          c.banned = true if ban_unknown
        end
        c.version = version
        c
      end
  end
end