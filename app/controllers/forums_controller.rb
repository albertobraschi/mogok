
class ForumsController < ApplicationController
  before_filter :logged_in_required
  before_filter :owner_required, :only => [:new, :destroy]
  before_filter :admin_required, :only => [:edit, :switch_lock]

  def index
    logger.debug ':-) forums_controller.index'
    @forums = Forum.all
  end

  def show
    logger.debug ':-) forums_controller.show'
    params[:keywords] = ApplicationHelper.process_search_keywords params[:keywords], 3
    @forum = Forum.find params[:id]
    @topics = @forum.search params, :per_page => APP_CONFIG[:page_size][:forum_topics]
  end

  def search
    logger.debug ':-) forums_controller.search'
    params[:keywords] = ApplicationHelper.process_search_keywords params[:keywords], 3
    unless params[:keywords].blank?
      @topics = Forum.search_all params, :per_page => APP_CONFIG[:page_size][:forum_search_results]
    else
      redirect_to :action => 'index'
    end
  end

  def new
    logger.debug ':-) forums_controller.new'
    @forum = Forum.new params[:forum]
    if request.post?
      if @forum.save
        redirect_to :action => 'index'
      end
    end
  end

  def edit
    logger.debug ':-) forums_controller.edit'
    @forum = Forum.find params[:id]
    if request.post?      
      if @forum.update_attributes params[:forum]
        redirect_to :action => 'index'
      end
    end
  end

  def destroy
    logger.debug ':-) forums_controller.destroy'
    @forum = Forum.find params[:id]
    if request.post?
      unless cancelled?
        @forum.destroy
        flash[:notice] = 'Forum successfully removed.'
        redirect_to :action => 'index'
      else
        redirect_to :action => 'show', :id => @forum
      end
    end
  end

  def switch_lock_topics
    logger.debug ':-) forums_controller.switch_lock_topics'
    f = Forum.find params[:id]
    f.toggle! :topics_locked
    redirect_to :action => 'show', :id => f
  end
end















