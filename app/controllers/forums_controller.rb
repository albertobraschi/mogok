
class ForumsController < ApplicationController
  before_filter :login_required
  before_filter :owner_required, :only => [:new, :destroy]
  before_filter :admin_required, :only => [:edit, :switch_lock]

  def index
    logger.debug ':-) forums_controller.index'
    @forums = Forum.find :all, :order => 'position'
  end

  def show
    logger.debug ':-) forums_controller.show'
    params[:keywords] = ApplicationHelper.process_search_keywords params[:keywords], 3
    @forum = Forum.find params[:id]
    @topics = Topic.paginate_by_forum_id @forum,
                                         :conditions => show_conditions(params),
                                         :order => 'stuck DESC, last_post_at DESC',
                                         :per_page => APP_CONFIG[:forum_topics_page_size],
                                         :page => current_page
  end

  def search
    logger.debug ':-) forums_controller.search'
    params[:keywords] = ApplicationHelper.process_search_keywords params[:keywords], 3
    unless params[:keywords].blank?
      @topics = Topic.paginate :conditions => search_conditions(params),
                               :order => 'last_post_at DESC',
                               :per_page => APP_CONFIG[:forum_search_results_page_size],
                               :page => current_page
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

  def switch_lock
    logger.debug ':-) forums_controller.switch_lock'
    f = Forum.find params[:id]
    f.toggle! :locked
    redirect_to :action => 'show', :id => f
  end

  private

  def show_conditions(params)
    search_conditions params
  end

  def search_conditions(params)
    s, h = '', {}
    unless params[:keywords].blank?
      s << 'id IN (SELECT topic_id FROM topic_fulltexts WHERE MATCH(body) AGAINST (:keywords IN BOOLEAN MODE) ) '
      h[:keywords] = params[:keywords]
    end
    [s, h]
  end
end















