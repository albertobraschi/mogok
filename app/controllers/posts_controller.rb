
class PostsController < ApplicationController
  before_filter :login_required
  before_filter :admin_mod_required, :only => :show

  def show
    logger.debug ':-) posts_controller.show'
    @post = Post.find params[:id]
  end

  def new
    logger.debug ':-) posts_controller.new'
    @topic = Topic.find params[:topic_id]
    access_denied if @topic.locked? && !logged_user.admin_mod?
    unless params[:body].blank?
      @topic.add_post params, logged_user
      flash[:notice] = t('success')      
    else
      flash[:error] = t('empty')      
    end
    redirect_to_topic @topic.id, 'last'
  end
  
  def quote
    logger.debug ':-) posts_controller.quote'
    @post = Post.find params[:id]
  end
  
  def edit
    logger.debug ':-) posts_controller.edit'
    @post = Post.find params[:id]
    access_denied unless @post.editable_by? logged_user
    if request.post?
      logger.debug ':-) post request'
      unless cancelled?
        unless params[:body].blank?
          @post.edit params, logged_user
          logger.debug ':-) post saved'
          flash[:notice] = t('success')
          redirect_to_topic
        else
          flash[:error] = t('empty')
        end
      else
        redirect_to_topic
      end      
    end
  end

  def report
    logger.debug ':-) posts_controller.report'
    @post = Post.find params[:id]
    if request.post?
      unless cancelled?
        unless params[:reason].blank?
          target_path = posts_path(:forum_id => @post.forum_id, :action => 'show', :id => @post)
          Report.create @post, target_path, logged_user, params[:reason]
          flash[:notice] = t('success')
          redirect_to_topic
        else
          flash.now[:error] = t('reason_required')
        end
      else
        redirect_to_topic
      end
    end
  end

  private

  def redirect_to_topic(topic_id = nil, page = nil)
    topic_id ||= @post.topic_id
    page ||= params[:page]
    redirect_to topics_path(:action => 'show', :id => topic_id, :page => page)
  end
end















