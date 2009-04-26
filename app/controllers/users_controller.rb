
class UsersController < ApplicationController
  include MessageNotification
  before_filter :login_required
  before_filter :admin_required, :only => [:new, :destroy]
    
  def index
    logger.debug ':-) users_controller.index'
    params[:order_by] = 'username' if params[:order_by].blank?
    params[:username] = nil if params[:username] && params[:username].size < 3    

    @users = User.paginate :conditions => index_conditions(params), 
                           :page => current_page,
                           :order => index_order_by(params),
                           :per_page => APP_CONFIG[:users_page_size]
                         
    @users.desc_by_default = APP_CONFIG[:users_desc_by_default]
    @users.order_by = params[:order_by]
    @roles = Role.all_for_search
    @countries = Country.cached_all
  end 
  
  def show
    logger.debug ':-) users_controller.show'
    @user = User.find params[:id]
  end  

  def new
    logger.debug ':-) users_controller.new'
    @user = User.new params[:user]
    unless request.post?
      @user.avatar = APP_CONFIG[:default_avatar]
    else
      logger.debug ':-) post request'
      unless cancelled?
        @user.role = Role.find_by_name(Role::USER)
        if @user.valid?
          @user.created_at = Time.now
          @user.inviter = logged_user
          @user.reset_passkey
          @user.save
          logger.debug ":-) user created. id: #{@user.id}"
          redirect_to :action => 'show', :id => @user
        else
          logger.error ':-o user not created'
          @user.password = @user.password_confirmation = ''
        end
      else
        redirect_to :action => 'index'
      end
    end
    @genders = Gender.cached_all
    @countries = Country.cached_all
    @styles = Style.cached_all
  end
  
  def edit
    logger.debug ':-) users_controller.edit'
    @user = User.find params[:id]
    access_denied unless @user.editable_by? logged_user
    if request.post?
      logger.debug ':-) post request'
      unless cancelled?
        if @user.set_attributes params[:user], logged_user, params[:current_password]
          @user.avatar = APP_CONFIG[:default_avatar] if @user.avatar.blank?
          if @user.save 
            logger.debug ':-) user saved'
            flash[:notice] = t('controller.users.edit.success')
            redirect_to :action => 'show', :id => @user
          else
            logger.error ':-o user not saved'
            @user.password = @user.password_confirmation = ''
          end
        end
      else
        redirect_to :action => 'show', :id => @user
      end
    end
    @genders = Gender.cached_all
    @countries = Country.cached_all
    @styles = Style.cached_all
    if logged_user.admin?
      @roles = logged_user.owner? ? Role.all_for_owner : Role.all_for_admin
    end
  end

  def destroy
    logger.debug ':-) users_controller.destroy'
    @user = User.find params[:id]
    access_denied if !@user.editable_by?(logged_user) || @user == logged_user
    if request.post?
      logger.debug ':-) post request'
      unless cancelled?
        @user.destroy
        logger.debug ':-) user destroyed'        
        flash[:notice] = t('controller.users.destroy.success')
        add_log t('controller.users.destroy.log', :user => @user.username, :by => logged_user.username)
        redirect_to :action => 'index'
      else
        redirect_to :action => 'show', :id => @user
      end
    end
  end
  
  def reset_passkey
    logger.debug ':-) users_controller.reset_passkey'
    @user = User.find params[:id]
    access_denied if @user != logged_user && !@user.admin?
    if request.post?
      unless cancelled?
        @user.reset_passkey
        @user.save
        add_log t('controller.users.reset_passkey.log', :user => @user.username, :by => logged_user.username), nil, true
        notify_passkey_reset @user if @user != logged_user
        logger.debug ':-) paskey reset'
        flash[:notice] = t('controller.users.reset_passkey.success')
      end
      redirect_to :action => 'show', :id => @user
    end
  end

  def edit_staff_info
    logger.debug ':-) users_controller.edit_staff_info'
    ticket_required(:staff)
    @user = User.find params[:id]
    if request.post?
      logger.debug ':-) post request'
      unless cancelled?
        @user.update_attribute :staff_info, params[:staff_info]
      end
      redirect_to :action => 'show', :id => @user
    end
  end

  def report
    logger.debug ':-) TorrentsController.report'
    @user = User.find params[:id]
    if request.post?
      unless cancelled?
        unless params[:reason].blank?
          target_path = url_for :action => 'show', :id => @user, :only_path => true
          Report.create :created_at => Time.now, :label => "user [#{@user.username}]", :target_path => target_path, :user => logged_user, :reason => params[:reason]
          flash[:notice] = t('controller.users.report.success')
          redirect_to :action => 'show', :id => @user
        else
          flash.now[:error] = t('controller.users.reset_passkey.reason_required')
        end
      else
        redirect_to :action => 'show', :id => @user
      end
    end
  end

  def bookmarks
    logger.debug ':-) users_controller.bookmarks'
    @torrents = Torrent.paginate :conditions => bookmarks_conditions,
                                 :order => 'category_id, name',
                                 :page => current_page,
                                 :per_page => 20,
                                 :include => :tags
    @torrents.each {|t| t.bookmarked = true} if @torrents
  end

  def uploads
    logger.debug ':-) users_controller.uploads'
    params[:order_by], params[:desc]= 'created_at', '1' if params[:order_by].blank?
    @torrents = Torrent.scoped_by_active(true).paginate_by_user_id logged_user,
                                                                   :order => order_by,
                                                                   :page => current_page,
                                                                   :per_page => 20,
                                                                   :include => :tags
    set_bookmarked @torrents
    unless @torrents.blank?
      @torrents.desc_by_default = APP_CONFIG[:torrents_desc_by_default]
      @torrents.order_by = params[:order_by]
    end
  end
  
  def show_activity
    logger.debug ':-) users_controller.show_activity'
    @seeding = params[:seeding] == '1'
    @user = User.find params[:id]
    if !@seeding && @user != logged_user && !logged_user.admin?
      access_denied unless @user.display_downloads?
    end
    @peers = Peer.paginate_by_user_id @user,
                                      :conditions => {:seeder => @seeding},
                                      :order => 'started_at DESC',
                                      :page => current_page,
                                      :per_page => APP_CONFIG[:user_activity_page_size]
  end  
  
  def show_uploads
    logger.debug ':-) users_controller.show_uploads'
    @torrents = Torrent.paginate_by_user_id params[:id],
                                            :conditions => {:active => true},
                                            :order => 'created_at DESC',
                                            :page => current_page,
                                            :per_page => APP_CONFIG[:user_history_page_size],
                                            :include => :tags
  end  
  
  def show_snatches
    logger.debug ':-) users_controller.show_snatches'
    @user = User.find params[:id]
    if @user != logged_user && !logged_user.admin?
      access_denied unless @user.display_downloads?
    end
    @snatches = Snatch.paginate_by_user_id @user,
                                           :order => 'created_at DESC',
                                           :page => current_page,
                                           :per_page => APP_CONFIG[:user_history_page_size]
  end
  
  private
  
  def index_order_by(params)
   if params[:order_by] == 'ratio'
     "uploaded/downloaded #{'DESC' if params[:desc] == '1'}"
   else
     order_by
   end
  end

  def index_conditions(params)
    s, h = '', {}
    unless logged_user.system_user?
      s << 'id != 1 ' # system user won't be listed
      previous = true
    end
    unless params[:username].blank?
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
  
  def set_bookmarked(torrents)
    unless torrents.blank?
      unless logged_user.bookmarks.blank?
        torrents.each do |t|
          logged_user.bookmarks.each {|b| t.bookmarked = true if t.id == b.torrent_id }
        end
      end
    end
  end

  def bookmarks_conditions
    s, h = '', {}
    unless logged_user.admin_mod?
      s << 'active = TRUE '
      previous = true
    end
    s << 'AND ' if previous
    s << 'id in (SELECT torrent_id FROM bookmarks WHERE user_id = :user_id)'
    h[:user_id] = logged_user.id
    [s, h]
  end
end



















