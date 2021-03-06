
class User

  # finders concern

  def self.system_user
    find 1
  end

  def paginate_uploads(params, args)
    Torrent.scoped_by_active(true).paginate_by_user_id self,
                                                       :order => self.class.order_by(params[:order_by], params[:desc]),
                                                       :page => params[:page],
                                                       :per_page => args[:per_page],
                                                       :include => :tags
  end

  def paginate_wishes(params, args)
    Wish.paginate_by_user_id self,
                             :order => self.class.order_by(params[:order_by], params[:desc]),
                             :page => params[:page],
                             :per_page => args[:per_page]
  end

  def paginate_bookmarks(params, args)
    Torrent.paginate :conditions => paginate_bookmarks_conditions,
                     :order => 'name',
                     :page => params[:page],
                     :per_page => args[:per_page],
                     :include => :tags
  end

  def paginate_stuck(params, args)
    Torrent.paginate :conditions => stuck_conditions,
                     :order => 'leechers_count DESC, name',
                     :page => params[:page],
                     :per_page => args[:per_page],
                     :include => :tags
  end


  def paginate_invitees(params, args)
    self.class.paginate_by_inviter_id self.id,
                                      :order => 'created_at',
                                      :page => params[:page],
                                      :per_page => args[:per_page]
  end

  def paginate_messages(args)
    Message.paginate_by_owner_id self.id,
                                 :conditions => {:folder => args[:folder]},
                                 :order => 'created_at DESC',
                                 :page => args[:page],
                                 :per_page => args[:per_page]
  end

  def paginate_snatches(params, args)
    Snatch.paginate_by_user_id self,
                               :order => 'created_at DESC',
                               :page => params[:page],
                               :per_page => args[:per_page]
  end

  def paginate_peers(params, args)
    Peer.paginate_by_user_id self,
                             :conditions => {:seeder => params[:seeding] == '1'},
                             :order => 'started_at DESC',
                             :page => params[:page],
                             :per_page => args[:per_page]
  end

  def self.search(params, searcher, args)
    params[:username] = nil if params[:username] && params[:username].size < 3

    paginate :conditions => search_conditions(params, searcher),
             :order => order_by(params[:order_by], params[:desc]),
             :page => params[:page],
             :per_page => args[:per_page]
  end

  def self.top_uploaders(args)
    find :all, :order => 'uploaded DESC', :conditions => 'uploaded > 0', :limit => args[:limit]
  end

  def self.top_contributors(args)
    q, a = '', []
    q << 'SELECT user_id, COUNT(*) AS uploads '
    q << '  FROM torrents '
    q << '  WHERE user_id IS NOT NULL '
    q << '  GROUP BY user_id '
    q << '  ORDER BY uploads DESC '
    q << "  LIMIT #{args[:limit]}"
    result = connection.select_all q
    result.each {|r| a << {:user => find(r['user_id']), :torrents => r['uploads']} }
    a
  end

  private

    def paginate_bookmarks_conditions
      s, h = '', {}
      unless admin_mod?
        s << 'active = TRUE '
        previous = true
      end
      s << 'AND ' if previous
      s << 'id in (SELECT torrent_id FROM bookmarks WHERE user_id = :user_id)'
      h[:user_id] = self.id
      [s, h]
    end

    def stuck_conditions
      s, h = '', {}
      s << 'active = TRUE AND seeders_count = 0 AND leechers_count > 0 '
      s << 'AND '
      s << '(user_id = :user_id OR id IN (SELECT torrent_id FROM snatches WHERE user_id = :user_id))'
      h[:user_id] = self.id
      [s, h]
    end

    def self.search_conditions(params, searcher)
      s, h = '', {}
      unless searcher.system?
        s << 'id != 1 ' # hide system user
        previous = true
      end
      unless params[:username].blank?
        s << 'AND ' if previous
        s << 'username LIKE :username '
        h[:username] = "%#{params[:username]}%"
        previous = true
      end
      unless params[:role_id].blank?
        s << 'AND ' if previous
        s << 'role_id = :role_id '
        h[:role_id] = params[:role_id].to_i
        previous = true
      end
      unless params[:country_id].blank?
        s << 'AND ' if previous
        s << 'country_id = :country_id '
        h[:country_id] = params[:country_id].to_i
      end
      [s, h]
    end
end
