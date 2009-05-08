
class TopicsController < ApplicationController
  before_filter :login_required
  before_filter :admin_mod_required, :only => [:destroy, :stick, :switch_lock]

  def show
    logger.debug ':-) topics_controller.show'
    @topic = Topic.find params[:id]
    @posts = @topic.paginate_posts params, :per_page => APP_CONFIG[:forum_posts_page_size]
  end

  def new
    logger.debug ':-) topics_controller.new'
    @forum = Forum.find params[:forum_id]
    access_denied if @forum.locked? && !logged_user.admin_mod?
    if request.post?
      logger.debug ':-) post request'
      unless cancelled?
        unless params[:title].blank? || params[:body].blank?
          t = @forum.add_topic(params, logged_user)
          flash[:notice] = t('controller.topics.new.success')
          redirect_to :action => 'show', :id => t
        else
          flash[:error] = t('controller.topics.new.empty')
        end
      else
        redirect_to forums_path(:action => 'show', :id => @forum)
      end
    end
  end

  def edit
    logger.debug ':-) topics_controller.edit'
    @topic = Topic.find params[:id]
    access_denied unless @topic.editable_by? logged_user
    unless request.post?
      params[:title], params[:body] = @topic.title, @topic.topic_post.body
    else
      unless cancelled?
        unless params[:title].blank? || params[:body].blank?
          @topic.edit params, logged_user
          flash[:notice] = t('controller.topics.edit.success')
          redirect_to :action => 'show', :id => @topic
        else
          flash[:error] = t('controller.topics.edit.empty')
        end
      else
        redirect_to :action => 'show', :id => @topic
      end
    end
  end

  def destroy
    logger.debug ':-) topics_controller.destroy'
    @topic = Topic.find params[:id]
    if request.post?
      unless cancelled?
        @topic.destroy
        flash[:notice] = t('controller.topics.destroy.success')
        redirect_to forums_path(:action => 'show', :id => @topic.forum)
      else
        redirect_to :action => 'show', :id => @topic
      end
    end
  end

  def report
    logger.debug ':-) topics_controller.report'
    @topic = Topic.find params[:id]
    if request.post?
      unless cancelled?
        unless params[:reason].blank?
          target_path = topics_path(:forum_id => @topic.forum_id, :action => 'show', :id => @topic)
          Report.create @topic, target_path, logged_user, params[:reason]
          flash[:notice] = t('controller.topics.report.success')
          redirect_to topics_path(:action => 'show', :id => @topic)
        else
          flash.now[:error] = t('controller.topics.report.reason_required')
        end
      else
        redirect_to topics_path(:action => 'show', :id => @topic)
      end
    end
  end

  def switch_stick
    logger.debug ':-) topics_controller.switch_stick'
    t = Topic.find params[:id]
    t.toggle! :stuck
    redirect_to :action => 'show', :id => t
  end

  def switch_lock
    logger.debug ':-) topics_controller.switch_lock'
    t = Topic.find params[:id]
    t.toggle! :locked
    redirect_to :action => 'show', :id => t
  end
end















