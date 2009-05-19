 
module BgTasks

  class CleanupPeers < AbstractBgTask

    protected

      def do_exec(params)
        Peer.delete_inactives params[:peer_max_inactivity_minutes].minutes.ago
      end
  end
end
