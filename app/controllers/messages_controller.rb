
class MessagesController < ApplicationController
  before_filter :login_required
  rescue_from Message::NotOwnerError, :with => :access_denied

  def folder
    logger.debug ':-) messages_controller.folder'
    folder = params[:id].blank? ? Message::INBOX : params[:id]
    raise ArgumentError unless Message.valid_folder? folder
    page = params[:page].blank? ? 1 : params[:page].to_i

    @messages = Message.user_messages logged_user, params, :folder => folder, :per_page => APP_CONFIG[:messages_page_size]

    if logged_user.has_new_message? && folder == Message::INBOX && page == 1
      logged_user.toggle!(:has_new_message)
    end
    session[:messenger_folder] = folder
    session[:messenger_page] = page
  end
  
  def show
    logger.debug ':-) messages_controller.show'
    @message = Message.find params[:id]
    @message.ensure_ownership logged_user
    @message.set_read
  end
    
  def new
    logger.debug ':-) messages_controller.new'
    @message = Message.make_new params[:message],
                                logged_user,
                                :message_id => params[:message_id],
                                :to => params[:to],
                                :reply => params[:reply] == '1',
                                :forward => params[:forward] == '1'
    unless request.post?
      params[:to] = @message.replying_to if params[:reply] == '1'
    else
      unless cancelled?
        if @message.deliver(params[:replied_id])
          @message.owner.toggle! :has_new_message unless @message.owner.has_new_message?
          logger.debug ':-) message sent'
          flash[:notice] = t('controller.messages.new.success')
          redirect_to :action => 'folder', :id => session[:messenger_folder], :page => session[:messenger_page]
        end
      else
        redirect_to :action => 'folder', :id => session[:messenger_folder], :page => session[:messenger_page]
      end
    end
  end  

  def move
    logger.debug ':-) messages_controller.move'
    destination_folder = params[:destination_folder]
    raise ArgumentError unless Message.valid_folder? destination_folder
    unless cancelled?
      unless params[:id].blank? # user was reading a message and decided to move it
        Message.find(params[:id]).move_to_folder(destination_folder, logged_user)
        logger.debug ':-) message moved'
        flash[:notice] = t('controller.messages.move.moved_single')
      end
    end
    unless params[:selected_messages].blank? # user was browsing the messages and decided to move some
      messages = Message.find params[:selected_messages]
      messages.each {|m| m.move_to_folder(destination_folder, logged_user) }
      logger.debug ':-) messages moved'
      flash[:notice] = t('controller.messages.move.moved_list')
    end
    redirect_to :action => 'folder', :id => session[:messenger_folder], :page => session[:messenger_page]
  end
end






