
class PeerConn < ActiveRecord::Base
  has_many :peers

  index [:ip, :port] #cache_money

  def self.delete_peerless
    # delete peer_conns that don't have any associated peer
    connection.execute 'DELETE FROM peer_conns WHERE peer_conns.id NOT IN (SELECT DISTINCT peer_conn_id FROM peers)'
  end
end
