
class AnnounceLog < ActiveRecord::Base
  belongs_to :user
  belongs_to :torrent
  
  def self.create(announce_req)
    h = {}
    h[:user_id] = announce_req.user.id
    h[:torrent_id] = announce_req.torrent.id
    h[:event] = announce_req.event
    h[:seeder] = announce_req.seeder
    h[:ip] = announce_req.ip
    h[:port] = announce_req.port
    h[:up_offset] = announce_req.up_offset
    h[:down_offset] = announce_req.down_offset
    h[:created_at] = announce_req.current_action_at
    if announce_req.last_action_at
      h[:time_interval] = announce_req.current_action_at.to_i - announce_req.last_action_at.to_i
    end
    h[:client_code] = announce_req.client.code
    h[:client_name] = announce_req.client.name
    h[:client_version] = announce_req.client.version
    super h
  end

  def self.search(params, args)
    paginate :conditions => search_conditions(params),
             :order => order_by(params[:order_by], params[:desc]),
             :page => current_page(params[:page]),
             :per_page => args[:per_page]
  end

  private

    def self.search_conditions(params)
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
