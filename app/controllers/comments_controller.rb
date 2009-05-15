
class CommentsController < ApplicationController
  before_filter :login_required
  before_filter :admin_mod_required, :only => :show

  def show
    logger.debug ':-) comments_controller.show'
    @comment = Comment.find params[:id]
  end

  def new
    logger.debug ':-) comments_controller.new'
    t = Torrent.find params[:torrent_id]
    access_denied if t.comments_locked? && !current_user.admin_mod?
    unless params[:body].blank?
      t.add_comment params, current_user
      flash[:comment_notice] = t('success')
    else
      flash[:comment_error] = t('empty')
    end
    redirect_to_torrent t.id, 'last'
  end

  def quote
    logger.debug ':-) comments_controller.quote'
    @comment = Comment.find params[:id]
  end

  def edit
    logger.debug ':-) comments_controller.edit_comment'
    @comment = Comment.find params[:id]
    access_denied unless @comment.editable_by? current_user
    if request.post?
      unless cancelled?
        unless params[:body].blank?
          @comment.edit params, current_user
          logger.debug ':-) comment saved'
          flash[:comment_notice] = t('success')
          redirect_to_torrent
        else
          flash[:error] = t('empty')
        end
      else
        redirect_to_torrent
      end
    end
  end

  def report
    logger.debug ':-) comments_controller.report'
    @comment = Comment.find params[:id]
    if request.post?
      unless cancelled?
        unless params[:reason].blank?
          target_path = comments_path(:torrent_id => @comment.torrent_id, :action => 'show', :id => @comment)
          Report.create @comment, target_path, current_user, params[:reason]
          flash[:notice] = t('success')
          redirect_to_torrent
        else
          flash.now[:error] = t('reason_required')
        end
      else
        redirect_to_torrent
      end
    end
  end

  private

    def redirect_to_torrent(torrent_id = nil, page = nil)
      torrent_id ||= @comment.torrent_id
      page ||= params[:page]
      redirect_to torrents_path(:action => 'show',
                                :id => torrent_id,
                                :page => page,
                                :anchor => 'comments')
    end
end

