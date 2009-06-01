
class AnnounceLog < ActiveRecord::Base
  belongs_to :user
  belongs_to :torrent
  
  def self.search(params, args)
    paginate :conditions => search_conditions(params),
             :order => order_by(params[:order_by], params[:desc]),
             :page => current_page(params[:page]),
             :per_page => args[:per_page]
  end

  def self.delete_olds(threshold)
    delete_all ['created_at < ?', threshold]
  end

  def self.create(attributes)
    l = new
    l.set_attributes attributes
    l.save!
    logger.debug ':-) peer conn created'
    l
  end

  def set_attributes(h)
    self.torrent        = h[:torrent]
    self.user           = h[:user]
    self.event          = h[:event]
    self.seeder         = h[:seeder]
    self.ip             = h[:ip]
    self.port           = h[:port]
    self.up_offset      = h[:up_offset]
    self.down_offset    = h[:down_offset]
    self.time_interval  = h[:time_interval]
    self.client_code    = h[:client].code
    self.client_name    = h[:client].name
    self.client_version = h[:client].version
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
