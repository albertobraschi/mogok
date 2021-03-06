
class WishCommentsController < ApplicationController
  before_filter :logged_in_required
  before_filter :admin_mod_required, :only => :show

  def show
    logger.debug ':-) wish_comments_controller.show'
    @wish_comment = WishComment.find params[:id]
  end

  def new
    logger.debug ':-) wish_comments_controller.new'
    w = Wish.find params[:wish_id]
    access_denied if w.comments_locked? && !current_user.admin_mod?
    unless params[:comment_body].blank?
      w.add_comment params[:comment_body], current_user
      flash[:comment_notice] = t('success')
    else
      flash[:comment_error] = t('empty')
    end
    redirect_to_wish w.id, 'last'
  end

  def quote
    logger.debug ':-) wish_comments_controller.quote'
    @wish_comment = WishComment.find params[:id]
  end

  def edit
    logger.debug ':-) wish_comments_controller.edit_comment'
    @wish_comment = WishComment.find params[:id]
    access_denied unless @wish_comment.editable_by? current_user
    if request.post?
      unless cancelled?
        unless params[:comment_body].blank?
          @wish_comment.edit params[:comment_body], current_user
          logger.debug ':-) wish_comment saved'
          flash[:comment_notice] = t('success')
          redirect_to_wish
        else
          flash.now[:error] = t('empty')
        end
      else
        redirect_to_wish
      end
    end
  end

  def report
    logger.debug ':-) wish_comments_controller.report'
    @wish_comment = WishComment.find params[:id]
    if request.post?
      unless cancelled?
        unless params[:reason].blank?
          @wish_comment.report current_user, params[:reason], wish_comments_path(:wish_id => @wish_comment.wish_id, :action => 'show', :id => @wish_comment)
          flash[:comment_notice] = t('success')
          redirect_to_wish
        else
          flash.now[:error] = t('reason_required')
        end
      else
        redirect_to_wish
      end
    end
  end

  private

    def redirect_to_wish(wish_id = nil, page = nil)
      wish_id ||= @wish_comment.wish_id
      page ||= params[:page]
      redirect_to wishes_path(:action => 'show', :id => wish_id, :page => page, :anchor => 'comments')
    end
end

