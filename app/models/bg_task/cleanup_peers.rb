
class BgTask

  # cleanup_peers concern

  def self.cleanup_peers(params)
    Peer.delete_inactives params[:peer_max_inactivity_minutes].minutes.ago
  end
end
