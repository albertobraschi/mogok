
class TorrentsController < ApplicationController
  include TrackerHelper, MessageNotification
  before_filter :logged_in_required
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

    if !@perform_cache || (@perform_cache && expire_timed_fragment(@fragment_name)) # mogok_timed_fragment_cache plugin
      @torrents = Torrent.search params, current_user, :per_page => APP_CONFIG[:page_size][:torrents]
      @torrents.desc_by_default = APP_CONFIG[:desc_by_default][:torrents] unless @torrents.blank?
      @category = Category.find params[:category_id] unless params[:category_id].blank?
    end
    set_collections
  end  

  def show
    logger.debug ':-) torrents_controller.show'
    @torrent = Torrent.find_by_id params[:id]
    if torrent_available?
      @torrent.set_bookmarked current_user
      @mapped_files = MappedFile.cached_by_torrent(@torrent)
      @comments = @torrent.paginate_comments params, :per_page => APP_CONFIG[:page_size][:torrent_comments]
      @comments.html_anchor  = 'comments' if @comments
    end
  end  
  
  def edit
    logger.debug ':-) torrents_controller.edit'
    @torrent = Torrent.find_by_id params[:id]
    if torrent_available?
      access_denied unless @torrent.editable_by? current_user
      if request.post?
        unless cancelled?
          if @torrent.edit(params[:torrent], current_user, params[:reason])
            logger.debug ':-) torrent edited'            
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
      access_denied unless @torrent.editable_by? current_user
      if request.post?
        unless cancelled?
          if !@torrent.active? || params[:destroy] == '1'
            @torrent.destroy_with_notification(current_user, params[:reason])
            flash[:notice] = t('destroyed')
            redirect_to :action => 'index'
          else
            @torrent.inactivate(current_user, params[:reason])
            if current_user.admin_mod?
              flash[:notice] = t('inactivated')
              redirect_to :action => 'show', :id => @torrent
            else
              Report.create @torrent, torrents_path(:action => 'show', :id => @torrent), current_user, t('inactivated_report')
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
    t = Torrent.find params[:id]
    t.activate current_user
    flash[:notice] = t('success')
    redirect_to :action => 'show', :id => t
  end

  def report
    logger.debug ':-) torrents_controller.report'
    @torrent = Torrent.find_by_id params[:id]
    if torrent_available?
      if request.post?
        unless cancelled?
          unless params[:reason].blank?
            Report.create @torrent, torrents_path(:action => 'show', :id => @torrent), current_user, params[:reason]
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
    Bookmark.toggle_bookmarked @torrent, current_user
  end

  def switch_lock_comments
    logger.debug ':-) torrents_controller.switch_lock_comments'
    t = Torrent.find params[:id]
    t.toggle! :comments_locked
    redirect_to :action => 'show', :id => t
  end

  def upload
    logger.debug ':-) torrents_controller.upload'
    access_denied if !APP_CONFIG[:torrents][:upload_enabled] && !current_user.admin?
    @torrent = Torrent.new params[:torrent]
    if request.post?
      begin
        file_data = get_file_data params[:torrent_file]
        if @torrent.parse_and_save(current_user, file_data, true)
          flash[:alert] = t('success')
          redirect_to :action => 'show', :id => @torrent
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
      t.announce_url = make_announce_url t, current_user
      t.comment = APP_CONFIG[:torrents][:file_comment] if APP_CONFIG[:torrents][:file_comment]
      file_name = TorrentsHelper.torrent_file_name t, APP_CONFIG[:torrents][:file_prefix]
      send_data t.out, :filename => file_name, :type => 'application/x-bittorrent', :disposition => 'attachment'
    end
  end

  def show_peers
    logger.debug ':-) torrents_controller.show_peers'
    t = Torrent.find_by_id params[:id]
    @peers = t.paginate_peers params, :per_page => APP_CONFIG[:page_size][:torrent_peers] if t
  end  
  
  def show_snatches
    logger.debug ':-) torrents_controller.show_snatches'
    t = Torrent.find_by_id params[:id]
    @snatches = t.paginate_snatches params, :per_page => APP_CONFIG[:page_size][:torrent_snatches] if t
  end  
    
  private

    def torrent_available?(t = nil)
      t ||= @torrent
      if !t.blank? && (t.active? || current_user.admin_mod?)
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
        unless current_user.bookmarks.blank?
          torrents.each do |t|
            current_user.bookmarks.each {|b| t.bookmarked = true if t.id == b.torrent_id }
          end
        end
      end
    end

    def torrent_file_error(error_key, args = {})
      raise TorrentFileError.new(error_key, args)
    end

    def get_file_data(f)
      ensure_valid_uploaded_file(f)

      if f.respond_to? :string
        data = f.string
      elsif f.respond_to? :read
        data = f.read
      else
        raise 'unable to handle uploaded file, check how the web server treats file uploads'
      end
      data
    end

    def ensure_valid_uploaded_file(f)
      if f.blank?
        torrent_file_error 'required'
      else
        logger.debug ":-) file uploaded as #{f.class.name}"
        if f.respond_to?(:original_filename) && !f.original_filename.downcase.ends_with?('.torrent')
          torrent_file_error 'type'
        end
        if f.length > APP_CONFIG[:torrents][:file_max_size_kb].kilobytes
          torrent_file_error 'size', :max_size => APP_CONFIG[:torrents][:file_max_size_kb]
        end
      end
    end

    def index_perform_cache?
      !current_user.admin_mod? && # admin_mods can see inactive torrents
      params[:order_by] == 'created_at' && params[:desc] == '1' &&
      params[:keywords].blank? &&
      params[:category_id].blank? &&
      params[:format_id].blank? &&
      params[:country_id].blank? &&
      params[:tags_str].blank? &&
      params[:inactive].blank?
    end
end

