
class TorrentsController < ApplicationController
  include TrackerHelper, MessageNotification
  before_filter :login_required
  before_filter :admin_mod_required, :only => [:switch_lock_comments, :activate]
  cache_sweeper :torrents_sweeper, :only => [:upload, :remove]

  class TorrentFileError < StandardError
  end

  def index
    logger.debug ':-) torrents_controller.index'
    params[:keywords] = ApplicationHelper.process_search_keywords params[:keywords], 3
    params[:order_by], params[:desc]= 'created_at', '1' if params[:order_by].blank?
    
    @perform_cache = index_perform_cache?
    
    @fragment_name = "torrents.index.page.#{params[:page] || 1}"
    @search_box_fragment_name = 'torrents.index.search_box'

    if !@perform_cache || (@perform_cache && expire_timed_fragment(@fragment_name)) # check mogok_timed_fragment_cache plugin
      @torrents = Torrent.search params, logged_user, :per_page => APP_CONFIG[:torrents_page_size]
      @torrents.desc_by_default = APP_CONFIG[:torrents_desc_by_default] unless @torrents.blank?
      @category = Category.find params[:category_id] unless params[:category_id].blank?
    end
    if !@perform_cache || (@perform_cache && !read_fragment(@search_box_fragment_name))
      @categories = Category.cached_all
      @types = Type.cached_all
      @countries = Country.cached_all
    end
  end  

  def show
    logger.debug ':-) torrents_controller.show'
    @torrent = Torrent.find_by_id params[:id]
    if @torrent.blank? || (!@torrent.active? && !logged_user.admin_mod?)
      render :template => 'torrents/unavailable'
    else
      @torrent.set_bookmarked logged_user
      @mapped_files = MappedFile.cached_by_torrent(@torrent)
      @comments = Comment.torrent_comments @torrent, params, :per_page => APP_CONFIG[:torrent_comments_page_size]
      @comments.html_anchor  = 'comments' if @comments
    end
  end  
  
  def edit
    logger.debug ':-) torrents_controller.edit'
    @torrent = Torrent.find params[:id]
    access_denied unless @torrent.editable_by? logged_user
    raise ArgumentError if !@torrent.active? && !logged_user.admin_mod?
    if request.post?
      logger.debug ':-) post request'
      unless cancelled?
        @torrent.set_attributes params[:torrent]
        if @torrent.save
          logger.debug ':-) torrent saved'
          add_log t('controller.torrents.edit.log', :torrent => @torrent.name, :user => logged_user.username), params[:reason]
          flash[:notice] = t('controller.torrents.edit.success')
          redirect_to :action => 'show', :id => @torrent
        else
          logger.debug ':-o torrent not saved'
        end
      else
        redirect_to :action => 'show', :id => @torrent
      end      
    end
    @categories = Category.cached_all
    @types = Type.cached_all
    @countries = Country.cached_all
    @category = @torrent.category
  end
  
  def remove
    logger.debug ':-) torrents_controller.remove'
    @torrent = Torrent.find params[:id]
    access_denied unless @torrent.editable_by? logged_user
    raise ArgumentError if !@torrent.active? && !logged_user.admin_mod?
    if request.post?
      unless cancelled?
        if logged_user.admin_mod?
          if !@torrent.active? || params[:destroy] == '1'
            @torrent.destroy
            destroyed = true
            logger.debug ':-) torrent destroyed'
          end
        end
        if destroyed
          add_log t('controller.torrents.remove.destroyed_log', :torrent => @torrent.name, :user => logged_user.username), params[:reason]
          notify_torrent_deleted @torrent, logged_user, params[:reason] if @torrent.user != logged_user
          flash[:notice] = t('controller.torrents.remove.destroyed')
        else
          @torrent.inactivate
          logger.debug ':-) torrent inactivated'
          add_log t('controller.torrents.remove.inactivated_log', :torrent => @torrent.name, :user => logged_user.username), params[:reason]
          notify_torrent_inactivated @torrent, logged_user, params[:reason] if @torrent.user != logged_user
          flash[:notice] = t('controller.torrents.remove.inactivated')
        end
        redirect_to :action => 'index'
      else
        redirect_to :action => 'show', :id => @torrent
      end
    end
  end  

  def activate
    logger.debug ':-) torrents_controller.activate'
    @torrent = Torrent.find params[:id]
    @torrent.update_attribute :active, true
    add_log t('controller.torrents.activate.log', :torrent => @torrent.name, :user => logged_user.username)
    flash[:notice] = t('controller.torrents.activate.success')
    redirect_to :action => 'index'
  end

  def report
    logger.debug ':-) torrents_controller.report'
    @torrent = Torrent.find params[:id]
    if request.post?
      unless cancelled?
        unless params[:reason].blank?
          target_path = url_for :action => 'show', :id => @torrent, :only_path => true
          Report.create :created_at => Time.now, :label => "torrent [#{@torrent.id}]", :target_path => target_path, :user => logged_user, :reason => params[:reason]
          flash[:notice] = t('controller.torrents.report.success')
          redirect_to :action => 'show', :id => @torrent
        else
          flash.now[:error] = t('controller.torrents.report.reason_required')
        end
      else
        redirect_to :action => 'show', :id => @torrent
      end
    end
  end
  
  def bookmark
    logger.debug ':-) torrents_controller.bookmark'
    @torrent = Torrent.find params[:id]
    @bookmark = logged_user.bookmarks.find_by_torrent_id @torrent
    if @bookmark
      @bookmark.destroy
      @torrent.bookmarked = false
    else
      @bookmark = Bookmark.create :torrent_id => @torrent.id, :user_id => logged_user.id
      @torrent.bookmarked = true
    end
  end

  def switch_lock_comments
    logger.debug ':-) torrents_controller.switch_lock_comments'
    t = Torrent.find params[:id]
    t.toggle! :locked
    redirect_to :action => 'show', :id => t
  end

  def upload
    logger.debug ':-) torrents_controller.upload'
    access_denied if !APP_CONFIG[:torrent_upload_enabled] && !logged_user.admin?
    @torrent = Torrent.new params[:torrent]
    if request.post?
      logger.debug ':-) post request'
      @torrent.user = logged_user
      begin
        torrent_data = get_file_data params[:torrent_file]

        @torrent.set_meta_info(torrent_data, true, logger) # torrent file parsing
        
        if @torrent.save
          logger.debug ':-) torrent saved'
          add_log t('controller.torrents.upload.log', :torrent => @torrent.name, :user => logged_user.username)
          flash[:alert] = t('controller.torrents.upload.success')
          redirect_to :action => 'show', :id => @torrent
        end
      rescue TorrentFileError => e
        logger.debug ":-o torrent file error: #{e.message}"
        @torrent.errors.add :torrent_file, e.message
        @torrent.valid? # check if there are other errors to display in the view        
      end
      @category = @torrent.category
    end
    @categories = Category.cached_all
    @types = Type.cached_all
    @countries = Country.cached_all
    @category = @categories[0] unless @category
  end 
    
  def download
    logger.debug ':-) torrents_controller.download'
    t = Torrent.find_by_id params[:id]
    if t.blank? || (!t.active? && !logged_user.admin_mod?)
      render :template => 'torrents/unavailable'
    else
      t.announce_url = announce_url logged_user.announce_passkey(t)
      t.comment = APP_CONFIG[:torrent_file_comment] if APP_CONFIG[:torrent_file_comment]
      file_name = TorrentsHelper.torrent_file_name t, APP_CONFIG[:torrent_file_prefix]
      send_data t.out, :filename => file_name, :type => 'application/x-bittorrent', :disposition => 'attachment'
    end
  end

  def stuck
    logger.debug ':-) torrents_controller.stuck_torrents'
    @torrents = Torrent.stuck_by_user logged_user, params, :per_page => 20
    set_bookmarked @torrents
  end
    
  def show_peers
    logger.debug ':-) torrents_controller.show_peers'
    @peers = Peer.torrent_peers params[:id], params, :per_page => APP_CONFIG[:torrent_peers_page_size]
  end  
  
  def show_snatches
    logger.debug ':-) torrents_controller.show_snatches'
    @snatches = Snatch.torrent_snatches params[:id], params, :per_page => APP_CONFIG[:torrent_snatches_page_size]
  end  
    
  private

  def set_bookmarked(torrents)
    unless torrents.blank?
      unless logged_user.bookmarks.blank?
        torrents.each do |t|
          logged_user.bookmarks.each {|b| t.bookmarked = true if t.id == b.torrent_id }
        end
      end
    end
  end

  def raise_torrent_file_error(m)
    raise TorrentFileError.new(m)
  end

  def get_file_data(f)
    check_uploaded_file(f)
    
    if f.respond_to? :string
      data = f.string
    elsif f.respond_to? :read
      data = f.read
    else
      raise 'Unable to handle uploaded file, check how the web server treats file uploads.'
    end
    data
  end

  def check_uploaded_file(f)
    if f.blank?
      raise_torrent_file_error t('model.torrent.errors.torrent_file.required')
    else
      logger.debug ":-) file uploaded as #{f.class.name}"
      if f.respond_to? :original_filename
        raise_torrent_file_error t('model.torrent.errors.torrent_file.type') unless f.original_filename.downcase.ends_with? '.torrent'
      end
      if f.length > APP_CONFIG[:torrent_file_max_size_kb].kilobytes
        raise_torrent_file_error t('model.torrent.errors.torrent_file.size', :max_size => APP_CONFIG[:torrent_file_max_size_kb])
      end
    end
  end

  def index_perform_cache?
    !logged_user.admin_mod? && # admin_mods can see inactive torrents
    params[:order_by] == 'created_at' && params[:desc] == '1' &&
    params[:keywords].blank? &&
    params[:category_id].blank? &&
    params[:format_id].blank? &&
    params[:country_id].blank? &&
    params[:tags_str].blank? &&
    params[:inactive].blank?
  end
end

