
class PeersController < ApplicationController
  before_filter :logged_in_required
  before_filter :admin_required

  def index
    logger.debug ':-) peers_controller.index'
    @peers = Peer.search params, :per_page => APP_CONFIG[:peers_page_size]
  end

  def destroy
    if request.post?
      Peer.destroy params[:id]
    end
    redirect_to :action => 'index'
  end
end