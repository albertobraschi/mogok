
class PeersController < ApplicationController
  before_filter :login_required
  before_filter :admin_required

  def index
    logger.debug ':-) peers_controller.index'
    @peers = Peer.paginate :conditions => index_conditions(params),
                           :order => 'started_at DESC',
                           :page => current_page,
                           :per_page => APP_CONFIG[:peers_page_size]
  end

  def destroy
    if request.post?
      Peer.destroy params[:id]
    end
    redirect_to :action => 'index'
  end

  private

  def index_conditions(params)
    s, h = '', {}
    unless params[:user_id].blank?
      s << 'user_id = :user_id '
      h[:user_id] = params[:user_id].to_i
      previous = true
    end
    unless params[:torrent_id].blank?
      s << 'AND ' if previous
      s << 'torrent_id = :torrent_id '
      h[:torrent_id] = params[:torrent_id].to_i
      previous = true
    end
    if params[:seeder] == '1'
      params[:leecher] = '0'
      s << 'seeder = TRUE '
      previous = true
    elsif params[:leecher] == '1'
      s << 'seeder = FALSE '
      previous = true
    end
    unless params[:ip].blank?
      s << 'AND ' if previous
      s << 'ip = :ip '
      h[:ip] = params[:ip]
      previous = true
    end
    unless params[:port].blank?
      s << 'AND ' if previous
      s << 'port = :port '
      h[:port] = params[:port].to_i
    end
    [s, h]
  end
end