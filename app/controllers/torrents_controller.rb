
class TorrentsController < ApplicationController
  include TrackerHelper, MessageNotification
  before_filter :login_required
  before_filter :admin_mod_required, :only => [:switch_lock_comments, :activate]
  cache_sweeper :torrents_sweeper, :only => [:upload, :remove]

  class TorrentFileError < StandardError
    attr_accessor :args
    
    def initialize(error_key, args)
      super error_key
      self.args = args
    end
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
    set_collections
  end  

  def show
    logger.debug ':-) torrents_controller.show'
    @torrent = Torrent.find_by_id params[:id]
    if torrent_available?
      @torrent.set_bookmarked logged_user
      @mapped_files = MappedFile.cached_by_torrent(@torrent)
      @comments = @torrent.paginate_comments params, :per_page => APP_CONFIG[:torrent_comments_page_size]
      @comments.html_anchor  = 'comments' if @comments
    end
  end  
  
  def edit
    logger.debug ':-) torrents_controller.edit'
    @torrent = Torrent.find_by_id params[:id]
    if torrent_available?
      access_denied unless @torrent.editable_by? logged_user
      if request.post?
        logger.debug ':-) post request'
        unless cancelled?
          if @torrent.edit(params[:torrent])
            logger.debug ':-) torrent edited'
            add_log t('log', :torrent => @torrent.name, :user => logged_user.username), params[:reason]
            flash[:notice] = t('success')
            redirect_to :action => 'show', :id => @torrent
          else
            logger.debug ':-o torrent not edited'
          end
        else
          redirect_to :action => 'show', :id => @torrent
        end
      end
      set_collections
      @category = @torrent.category
    end
  end
  
  def remove
    logger.debug ':-) torrents_controller.remove'
    @torrent = Torrent.find_by_id params[:id]
    if torrent_available?
      access_denied unless @torrent.editable_by? logged_user
      if request.post?
        unless cancelled?
          if !@torrent.active? || params[:destroy] == '1'
            destroy_torrent
            flash[:notice] = t('destroyed_flash')
            redirect_to :action => 'index'
          else
            inactivate_torrent
            if logged_user.admin_mod?
              flash[:notice] = t('inactivated_flash')
              redirect_to :action => 'show', :id => @torrent
            else
              @args = {:title => t('inactivated_title'), :message => t('inactivated_message')}
              render :template => 'misc/message'
            end
          end
        else
          redirect_to :action => 'show', :id => @torrent
        end
      end
    end
  end  

  def activate
    logger.debug ':-) torrents_controller.activate'
    @torrent = Torrent.find params[:id]
    activate_torrent
    flash[:notice] = t('success')
    redirect_to :action => 'show', :id => @torrent
  end

  def report
    logger.debug ':-) torrents_controller.report'
    @torrent = Torrent.find_by_id params[:id]
    if torrent_available?
      if request.post?
        unless cancelled?
          unless params[:reason].blank?
            target_path = url_for :action => 'show', :id => @torrent, :only_path => true
            Report.create @torrent, target_path, logged_user, params[:reason]
            flash[:notice] = t('success')
            redirect_to :action => 'show', :id => @torrent
          else
            flash.now[:error] = t('reason_required')
          end
        else
          redirect_to :action => 'show', :id => @torrent
        end
      end
    end
  end
  
  def bookmark
    logger.debug ':-) torrents_controller.bookmark'
    @torrent = Torrent.find params[:id]
    Bookmark.toggle_bookmarked @torrent, logged_user
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
        if @torrent.set_meta_info(torrent_data, true, logger) # torrent file parsing
          if @torrent.save
            logger.debug ':-) torrent saved'
            add_log t('log', :torrent => @torrent.name, :user => logged_user.username)
            flash[:alert] = t('success')
            redirect_to :action => 'show', :id => @torrent
          end
        end
      rescue TorrentFileError => e
        logger.debug ":-o torrent file error: #{e.message}"
        @torrent.valid? # check other errors
        @torrent.add_error :torrent_file, e.message, e.args
      end
      @category = @torrent.category
    end
    set_collections
    @category = @categories[0] unless @category
  end 
    
  def download
    logger.debug ':-) torrents_controller.download'
    t = Torrent.find_by_id params[:id]
    if torrent_available?(t)
      t.announce_url = announce_url logged_user.announce_passkey(t)
      t.comment = APP_CONFIG[:torrent_file_comment] if APP_CONFIG[:torrent_file_comment]
      file_name = TorrentsHelper.torrent_file_name t, APP_CONFIG[:torrent_file_prefix]
      send_data t.out, :filename => file_name, :type => 'application/x-bittorrent', :disposition => 'attachment'
    end
  end

  def show_peers
    logger.debug ':-) torrents_controller.show_peers'
    t = Torrent.find_by_id params[:id]
    @peers = t.paginate_peers params, :per_page => APP_CONFIG[:torrent_peers_page_size] if t
  end  
  
  def show_snatches
    logger.debug ':-) torrents_controller.show_snatches'
    t = Torrent.find_by_id params[:id]
    @snatches = t.paginate_snatches params, :per_page => APP_CONFIG[:torrent_snatches_page_size] if t
  end  
    
  private

  def torrent_available?(t = nil)
    t ||= @torrent
    if !t.blank? && (t.active? || logged_user.admin_mod?)
      true
    else
      render :template => 'torrents/unavailable'
      false
    end
  end
  
  def set_collections
    @types = Type.cached_all
    @categories = Category.cached_all    
    @countries = Country.cached_all
  end

  def set_bookmarked(torrents)
    unless torrents.blank?
      unless logged_user.bookmarks.blank?
        torrents.each do |t|
          logged_user.bookmarks.each {|b| t.bookmarked = true if t.id == b.torrent_id }
        end
      end
    end
  end

  def destroy_torrent
    @torrent.destroy
    logger.debug ':-) torrent destroyed'
    add_log t('destroyed_log', :torrent => @torrent.name, :user => logged_user.username), params[:reason]
    if @torrent.user != logged_user
      s = t('destroyed_notification_subject')
      b = t('destroyed_notification_body', :name => @torrent.name, :by => logged_user.username, :reason => params[:reason])
      deliver_message_notification @torrent.user, s, b
    end
  end

  def inactivate_torrent
    @torrent.inactivate
    logger.debug ':-) torrent inactivated'
    add_log t('inactivated_log', :torrent => @torrent.name, :user => logged_user.username), params[:reason]
    if @torrent.user != logged_user
      s = t('inactivated_notification_subject')
      b = t('inactivated_notification_body', :name => @torrent.name, :by => logged_user.username, :reason => params[:reason])
      deliver_message_notification @torrent.user, s, b
    end
  end

  def activate_torrent
    @torrent.activate
    logger.debug ':-) torrent activated'
    add_log t('log', :torrent => @torrent.name, :user => logged_user.username)
    if @torrent.user != logged_user
      s = t('notification_subject')
      b = t('notification_body', :name => @torrent.name, :by => logged_user.username)
      deliver_message_notification @torrent.user, s, b
    end
  end
  
  def torrent_file_error(error_key, args = {})
    raise TorrentFileError.new(error_key, args)
  end

  def get_file_data(f)
    check_uploaded_file(f)
    
    if f.respond_to? :string
      data = f.string
    elsif f.respond_to? :read
      data = f.read
    else
      raise 'unable to handle uploaded file, check how the web server treats file uploads'
    end
    data
  end

  def check_uploaded_file(f)
    if f.blank?
      torrent_file_error 'required'
    else
      logger.debug ":-) file uploaded as #{f.class.name}"
      if f.respond_to?(:original_filename) && !f.original_filename.downcase.ends_with?('.torrent')
        torrent_file_error 'type'
      end
      if f.length > APP_CONFIG[:torrent_file_max_size_kb].kilobytes
        torrent_file_error 'size', :max_size => APP_CONFIG[:torrent_file_max_size_kb]
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

