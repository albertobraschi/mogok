
class MessagesController < ApplicationController
  before_filter :logged_in_required
  rescue_from Message::NotOwnerError, :with => :access_denied

  def folder
    logger.debug ':-) messages_controller.folder'
    params[:id] = Message::INBOX if params[:id].blank?
    params[:page] = '1' if params[:page].blank?

    folder, page = params[:id], params[:page].to_i

    if valid_folder?(folder)
      @messages = current_user.paginate_messages :page => page,
                                                :folder => folder,
                                                :per_page => APP_CONFIG[:page_size][:messages]
      toggle_new_message_alert folder, page
      session[:messenger_folder] = folder
      session[:messenger_page] = page
    end
  end
  
  def show
    logger.debug ':-) messages_controller.show'
    @message = Message.find params[:id]
    @message.ensure_ownership current_user
    @message.set_as_read
  end
    
  def new
    logger.debug ':-) messages_controller.new'
    @message = Message.make_new params[:message],
                                current_user,
                                :message_id => params[:message_id],
                                :to => params[:to],
                                :reply => params[:reply] == '1',
                                :forward => params[:forward] == '1'
    unless request.post?
      if params[:reply] == '1'
        params[:to] = @message.replying_to
      end
    else
      unless cancelled?
        if @message.deliver(params[:replied_id])          
          logger.debug ':-) message sent'
          flash[:notice] = t('success')
          redirect_to_folder
        end
      else
        redirect_to_folder
      end
    end
  end  

  def move
    logger.debug ':-) messages_controller.move'
    destination_folder = params[:destination_folder]
    raise ArgumentError unless Message.valid_folder? destination_folder
    unless cancelled?
      unless params[:id].blank? # user was reading a message and decided to move it
        Message.find(params[:id]).move_to_folder(destination_folder, current_user)
        logger.debug ':-) message moved'
        flash[:notice] = t('moved_single')
      end
    end
    unless params[:selected_messages].blank? # user was browsing the messages and decided to move some
      messages = Message.find params[:selected_messages]
      messages.each {|m| m.move_to_folder(destination_folder, current_user) }
      logger.debug ':-) messages moved'
      flash[:notice] = t('moved_list')
    end
    redirect_to_folder
  end

  private

    def redirect_to_folder
      redirect_to :action => 'folder', :id => session[:messenger_folder], :page => session[:messenger_page]
    end

    def valid_folder?(f)
      raise ArgumentError unless Message.valid_folder? f
      true
    end

    def toggle_new_message_alert(folder, page)
      if current_user.has_new_message? && folder == Message::INBOX && page == 1
        current_user.toggle! :has_new_message
      end
    end
end






