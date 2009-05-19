
class UsersController < ApplicationController
  include MessageNotification
  before_filter :logged_in_required
  before_filter :admin_required, :only => [:new, :destroy]
    
  def index
    logger.debug ':-) users_controller.index'
    params[:order_by] = 'username' if params[:order_by].blank?

    @users = User.search params, current_user, :per_page => APP_CONFIG[:page_size][:users]
    @users.desc_by_default = APP_CONFIG[:desc_by_default][:users]
    
    @roles = Role.all_for_search
    @countries = Country.cached_all
  end 
  
  def show
    logger.debug ':-) users_controller.show'
    @user = User.find params[:id]
    if @user.ratio_watch? && @user == current_user && flash.empty?
      flash.now[:ratio_watch] = t('ratio_watch', :until => l(@user.ratio_watch_until, :format => :date))
    end
  end  

  def new
    logger.debug ':-) users_controller.new'
    @user = User.new params[:user]
    if request.post?
      unless cancelled?
        if @user.valid?
          @user.inviter = current_user
          @user.save
          logger.debug ":-) user created. id: #{@user.id}"
          redirect_to :action => 'show', :id => @user
        else
          logger.debug ':-o user not created'
          @user.password = @user.password_confirmation = ''
        end
      else
        redirect_to :action => 'index'
      end
    end
    set_collections
  end
  
  def edit
    logger.debug ':-) users_controller.edit'
    @user = User.find params[:id]
    access_denied unless @user.editable_by? current_user
    if request.post?
      unless cancelled?
        if @user.edit(params[:user], current_user, params[:current_password], params[:update_counters] == '1')
          logger.debug ':-) user edited'
          flash[:notice] = t('success')
          redirect_to :action => 'show', :id => @user
        else
          logger.debug ':-o user not edited'
          @user.password = @user.password_confirmation = ''
        end
      else
        redirect_to :action => 'show', :id => @user
      end
    end
    set_collections    
    @roles = Role.all_for_user_edition(current_user) if current_user.admin?
  end

  def destroy
    logger.debug ':-) users_controller.destroy'
    @user = User.find params[:id]
    access_denied if !@user.editable_by?(current_user) || @user == current_user
    if request.post?
      unless cancelled?
        @user.destroy
        logger.debug ':-) user destroyed'        
        flash[:notice] = t('success')
        add_log t('log', :user => @user.username, :by => current_user.username)
        redirect_to :action => 'index'
      else
        redirect_to :action => 'show', :id => @user
      end
    end
  end
  
  def reset_passkey
    logger.debug ':-) users_controller.reset_passkey'
    @user = User.find params[:id]
    access_denied if @user != current_user && !current_user.admin?
    if request.post?
      unless cancelled?
        reset_user_passkey
        flash[:notice] = t('success')
      end
      redirect_to :action => 'show', :id => @user
    end
  end

  def edit_staff_info
    logger.debug ':-) users_controller.edit_staff_info'
    ticket_required(:staff)
    @user = User.find params[:id]
    if request.post?
      unless cancelled?
        @user.update_attribute :staff_info, params[:staff_info]
      end
      redirect_to :action => 'show', :id => @user
    end
  end

  def report
    logger.debug ':-) users_controller.report'
    @user = User.find params[:id]
    if request.post?
      unless cancelled?
        unless params[:reason].blank?
          Report.create @user, 
                        users_path(:action => 'show', :id => @user),
                        current_user,
                        params[:reason]
          flash[:notice] = t('success')
          redirect_to :action => 'show', :id => @user
        else
          flash.now[:error] = t('reason_required')
        end
      else
        redirect_to :action => 'show', :id => @user
      end
    end
  end

  def bookmarks
    logger.debug ':-) users_controller.bookmarks'
    @torrents = current_user.paginate_bookmarks params, :per_page => 20
    @torrents.each {|t| t.bookmarked = true} if @torrents
  end

  def uploads
    logger.debug ':-) users_controller.uploads'
    params[:order_by], params[:desc]= 'created_at', '1' if params[:order_by].blank?
    @torrents = current_user.paginate_uploads params, :per_page => APP_CONFIG[:page_size][:user_history]
    set_bookmarked @torrents
    unless @torrents.blank?
      @torrents.desc_by_default = APP_CONFIG[:desc_by_default][:torrents]
    end
  end

  def stuck
    logger.debug ':-) users_controller.stuck'
    @torrents = current_user.paginate_stuck params, :per_page => 20
    set_bookmarked @torrents
  end
  
  def show_activity
    logger.debug ':-) users_controller.show_activity'
    @seeding = params[:seeding] == '1'
    @user = User.find params[:id]
    if !@seeding && @user != current_user && !current_user.admin?
      access_denied unless @user.display_downloads?
    end
    @peers = @user.paginate_peers params, :per_page => APP_CONFIG[:page_size][:user_activity]
  end  
  
  def show_uploads
    logger.debug ':-) users_controller.show_uploads'
    params[:order_by], params[:desc]= 'created_at', '1'
    @user = User.find params[:id]
    @torrents = @user.paginate_uploads params, :per_page => APP_CONFIG[:page_size][:user_history]
  end  
  
  def show_snatches
    logger.debug ':-) users_controller.show_snatches'
    @user = User.find params[:id]
    if @user != current_user && !current_user.admin?
      access_denied unless @user.display_downloads?
    end
    @snatches = @user.paginate_snatches params, :per_page => APP_CONFIG[:page_size][:user_history]
  end
  
  private

    def set_collections
      @genders = Gender.cached_all
      @countries = Country.cached_all
      @styles = Style.cached_all
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

    def reset_user_passkey
      @user.reset_passkey!
      add_log t('log', :user => @user.username, :by => current_user.username), nil, true
      if @user != current_user
        deliver_message_notification @user, t('notification_subject'), t('notification_body')
      end
      logger.debug ':-) paskey reset'
    end
end



















