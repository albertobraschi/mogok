
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
      Post.transaction do
        @topic.replies_count = @topic.replies_count + 1
        @topic.last_post_at = Time.now
        @topic.last_post_by = logged_user.username
        @topic.save
        p = Post.new :user => logged_user, :topic => @topic, :forum_id => @topic.forum_id, :created_at => Time.now, :body => params[:body]
        p.post_number = @topic.replies_count + 1
        p.save
      end
      flash[:notice] = t('controller.posts.new.success')
      redirect_to topics_path(:action => 'show', :id => @topic, :page => 'last')
    else
      flash[:error] = t('controller.posts.new.empty')
      redirect_to topics_path(:action => 'show', :id => @topic, :page => params[:page])
    end    
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
          @post.body = params[:body]
          @post.edited_at, @post.edited_by = Time.now, logged_user.username
          if @post.save
            logger.debug ':-) post saved'
            flash[:notice] = t('controller.posts.edit.success')
            redirect_to topics_path(:action => 'show', :id => @post.topic_id, :page => params[:page])
          end
        else
          flash[:error] = t('controller.posts.edit.empty')
        end
      else
        redirect_to topics_path(:action => 'show', :id => @post.topic_id, :page => params[:page])
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
          Report.create :created_at => Time.now, :label => "post [#{@post.id}]", :target_path => target_path, :user => logged_user, :reason => params[:reason]
          flash[:notice] = t('controller.posts.report.success')
          redirect_to topics_path(:action => 'show', :id => @post.topic_id, :page => params[:page])
        else
          flash.now[:error] = t('controller.posts.report.reason_required')
        end
      else
        redirect_to topics_path(:action => 'show', :id => @post.topic_id, :page => params[:page])
      end
    end
  end
end















