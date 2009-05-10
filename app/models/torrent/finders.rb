
class Torrent

  # finders concern

  def paginate_comments(params, args)
    Comment.paginate_by_torrent_id self,
                                   :order => 'created_at',
                                   :page => self.class.current_page(params[:page]),
                                   :per_page => args[:per_page]
  end

  def paginate_peers(params, args)
    Peer.paginate_by_torrent_id self,
                                :order => 'started_at DESC',
                                :page => self.class.current_page(params[:page]),
                                :per_page => args[:per_page]
  end


  def paginate_snatches(params, args)
    Snatch.paginate_by_torrent_id self,
                                  :order => 'created_at DESC',
                                  :page => self.class.current_page(params[:page]),
                                  :per_page => args[:per_page]
  end


  def self.search(params, searcher, args)
    paginate :conditions => search_conditions(params, searcher),
             :order => order_by(params[:order_by], params[:desc]),
             :page => current_page(params[:page]),
             :per_page => args[:per_page],
             :include => :tags
  end

  private

  def self.search_conditions(params, searcher)
    s, h = '', {}
    if searcher.admin_mod?
      if params[:inactive] == '1'
        s << 'active = FALSE '
        previous = true
      end
    else
      s << 'active = TRUE '
      previous = true
    end
    unless params[:keywords].blank?
      s << 'AND ' if previous
      s << 'id IN (SELECT torrent_id FROM torrent_fulltexts WHERE MATCH(body) AGAINST (:keywords IN BOOLEAN MODE)) '
      h[:keywords] = params[:keywords]
      previous = true
    end
    unless params[:category_id].blank?
      s << 'AND ' if previous
      s << 'category_id = :category_id '
      h[:category_id] = params[:category_id].to_i
      previous = true
    end
    unless params[:format_id].blank?
      s << 'AND ' if previous
      s << 'format_id = :format_id '
      h[:format_id] = params[:format_id].to_i
      previous = true
    end
    unless params[:country_id].blank?
      s << 'AND ' if previous
      s << 'country_id = :country_id '
      h[:country_id] = params[:country_id].to_i
      previous = true
    end
    unless params[:tags_str].blank?
      if params[:category_id].blank?
        params[:tags_str] = ''
      else
        tags = Tag.parse_tags params[:tags_str], params[:category_id].to_i
        unless tags.blank?
          if tags.length > 3
            tags = tags[0, 3] # three tags maximum
          end
          params[:tags_str] = tags.join ', ' # show user which tags were used in search
          s << 'AND ' if previous
          s << 'id IN '
          s << "(SELECT torrent_id FROM tags_torrents WHERE tag_id = #{tags[0].id} "
          unless tags[1].blank?
            s << "AND torrent_id IN (SELECT torrent_id FROM tags_torrents WHERE tag_id = #{tags[1].id} "
            unless tags[2].blank?
              s << "AND torrent_id IN (SELECT torrent_id FROM tags_torrents WHERE tag_id = #{tags[2].id})"
            end
            s << ')'
          end
          s << ')'
        end
      end
    end
    [s, h]
  end
end
