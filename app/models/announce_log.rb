
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
    h[:created_at] = announce_req.current_action
    if announce_req.last_action_at
      h[:time_interval] = announce_req.current_action.to_i - announce_req.last_action_at.to_i
    end
    h[:client_code] = announce_req.client.code
    h[:client_name] = announce_req.client.name
    h[:client_version] = announce_req.client.version
    super h
  end
end
