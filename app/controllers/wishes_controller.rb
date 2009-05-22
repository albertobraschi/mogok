
class WishesController < ApplicationController
  include MessageNotification
  before_filter :logged_in_required
  before_filter :admin_mod_required, :only => [:switch_lock_comments, :approve, :reject]

  def index
    logger.debug ':-) wishes_controller.index'
    params[:keywords] = ApplicationHelper.process_search_keywords params[:keywords], 3
    params[:order_by], params[:desc]= 'created_at', '1' if params[:order_by].blank?

    @wishes = Wish.search params, :per_page => APP_CONFIG[:page_size][:wishes]
    @wishes.desc_by_default = APP_CONFIG[:desc_by_default][:wishes] unless @wishes.blank?
    
    @category = Category.find params[:category_id] unless params[:category_id].blank?
    set_collections
  end

  def new
    logger.debug ':-) wishes_controller.new'
    ticket_required :wisher
    @wish = Wish.new params[:wish]
    if request.post?
      @wish.user = current_user      
      if @wish.save
        flash[:notice] = t('success')
        redirect_to :action => 'show', :id => @wish
      end
      @category = @wish.category
    end
    set_collections
    @category = @categories[0] unless @category
  end

  def show
    logger.debug ':-) wishes_controller.show'
    @wish = Wish.find params[:id]
    @wish_comments = @wish.paginate_comments params, :per_page => APP_CONFIG[:page_size][:torrent_comments]
    @comments.html_anchor  = 'comments' if @comments
  end

  def edit
    logger.debug ':-) wishes_controller.edit'
    @wish = Wish.find params[:id]
    access_denied unless @wish.editable_by? current_user
    if request.post?
      unless cancelled?
        if @wish.edit(params[:wish])
          logger.debug ':-) wish edited'
          flash[:notice] = t('success')
          redirect_to :action => 'show', :id => @wish
        else
          logger.debug ':-o wish not edited'
        end
      else
        redirect_to :action => 'show', :id => @wish
      end      
    end
    set_collections
    @category = @wish.category
  end

  def destroy
    logger.debug ':-) wishes_controller.remove'
    @wish = Wish.find params[:id]
    access_denied unless @wish.editable_by? current_user
    if request.post?
      unless cancelled?
        @wish.destroy_with_notification current_user, params[:reason]
        flash[:notice] = t('success')
        redirect_to :action => 'index'
      else
        redirect_to :action => 'show', :id => @wish
      end
    end
  end

  def fill
    logger.debug ':-) wishes_controller.fill'
    @wish = Wish.find params[:id]
    access_denied if @wish.user == current_user
    if request.post?
      unless cancelled?
        t = Torrent.find_by_info_hash_hex params[:info_hash]
        case
          when t.blank?
            flash.now[:error] = t('info_hash_invalid')
          when Wish.find_by_torrent_id(t)
            flash.now[:error] = t('torrent_taken')
          when t.user != current_user
            flash.now[:error] = t('not_torrent_uploader')
          when @wish.user == t.user
            flash.now[:error] = t('same_user')
          else
            @wish.fill t
            Report.create @wish, wishes_path(:action => 'show', :id => @wish), current_user, t('report')
            flash[:notice] = t('success')
            redirect_to :action => 'show', :id => @wish
        end
      else
        redirect_to :action => 'show', :id => @wish
      end
    end
  end

  def approve
    logger.debug ':-) wishes_controller.approve'
    @wish = Wish.find params[:id]
    if request.post?
      @wish.approve
      flash[:notice] = t('success')
      redirect_to :action => 'show', :id => @wish
    end
  end

  def reject
    logger.debug ':-) wishes_controller.reject'
    @wish = Wish.find params[:id]
    if request.post?
      @wish.reject current_user, params[:reason]
      flash[:notice] = t('success')
      redirect_to :action => 'show', :id => @wish
    end
  end

  def report
    logger.debug ':-) wishes_controller.report'
    @wish = Wish.find params[:id]
    if request.post?
      unless cancelled?
        unless params[:reason].blank?
          Report.create @wish, wishes_path(:action => 'show', :id => @wish), current_user, params[:reason]
          flash[:notice] = t('success')
          redirect_to :action => 'show', :id => @wish
        else
          flash.now[:error] = t('reason_required')
        end
      else
        redirect_to :action => 'show', :id => @wish
      end
    end
  end

  def switch_lock_comments
    logger.debug ':-) wishes_controller.switch_lock_comments'
    w = Wish.find params[:id]
    w.toggle! :comments_locked
    redirect_to :action => 'show', :id => w
  end

  private

    def set_collections
      @types = Type.cached_all
      @categories = Category.cached_all
      @countries = Country.cached_all
    end
end



