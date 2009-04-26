
class MessagesController < ApplicationController
  before_filter :login_required

    
  def folder
    logger.debug ':-) messages_controller.folder'
    folder = params[:id].blank? ? Message::INBOX : params[:id]
    raise ArgumentError unless Message.valid_folder? folder
    @messages = Message.paginate_by_owner_id logged_user,
                                             :conditions => {:folder => folder},
                                             :order => 'created_at DESC',
                                             :per_page => APP_CONFIG[:messages_page_size],
                                             :page => current_page
    if logged_user.has_new_message? && folder == Message::INBOX && current_page == 1
      logged_user.toggle! :has_new_message
    end
    session[:messenger_folder] = folder
    session[:messenger_page] = current_page != 1 ? current_page : nil
  end
  
  def show
    logger.debug ':-) messages_controller.show'
    @message = Message.find params[:id]
    ensure_ownership @message
    @message.toggle! :unread if @message.unread?
  end
    
  def new
    logger.debug ':-) messages_controller.new'
    @message = Message.new params[:message]
    unless request.post?
      unless params[:message_id].blank?
        old_message = Message.find params[:message_id]
        ensure_ownership old_message
        prepare_to_reply @message, old_message if params[:reply] == '1'
        prepare_to_forward @message, old_message if params[:forward] == '1'
      end
    else
      unless cancelled?
        prepare_new_message @message
        unless @message.receiver.system_user?
          if @message.save
            save_sent if logged_user.save_sent
            delete_replied if logged_user.delete_on_reply && !params[:replied_id].blank?
            @message.owner.toggle! :has_new_message unless @message.owner.has_new_message?
            logger.debug ':-) message sent'
            flash[:notice] = t('controller.messages.new.success')
            redirect_to :action => 'folder', :id => session[:messenger_folder], :page => session[:messenger_page]
          else
            logger.debug ':-o message not sent'
          end
        else
          flash.now[:error] = t('controller.messages.new.for_system')
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
        message = Message.find params[:id]
        ensure_ownership message
        message.update_attribute :folder, destination_folder
        logger.debug ':-) message moved'
        flash[:notice] = t('controller.messages.move.moved_single')
      end
    end
    unless params[:selected_messages].blank? # user was browsing the messages and decided to move some
      messages = Message.find params[:selected_messages]
      messages.each do |m|
        ensure_ownership m
        m.folder = destination_folder
        m.save
      end
      logger.debug ':-) messages moved'
      flash[:notice] = t('controller.messages.move.moved_list')
    end
    redirect_to :action => 'folder', :id => session[:messenger_folder], :page => session[:messenger_page]
  end

  private

  def ensure_ownership(m)
    access_denied unless m.owned_by? logged_user
  end

  def prepare_new_message(m)
    m.owner = m.receiver = User.find_by_username(params[:to])
    m.sender = logged_user
    m.created_at = Time.now
    m.subject = t('controller.messages.prepare_new_message.no_subject') if @message.subject.blank?
    m.unread = true
    m.folder = Message::INBOX
  end

  def prepare_to_reply(m, old_message)
    m.subject = "#{ 'Re: ' unless old_message.subject.starts_with?('Re:') }#{old_message.subject}"
    m.body = "\n\n\n----
              \n#{old_message.sender.username} #{t('controller.messages.prepare_to_reply.wrote')}:
              \n\n#{old_message.body}"
    params[:to] = old_message.sender.username
  end

  def prepare_to_forward(m, old_message)
    m.subject = "#{ 'Fwd: ' unless old_message.subject.starts_with?('Fwd:') }#{old_message.subject}"
    m.body = "\n\n\n----
             \n#{old_message.sender.username} #{t('controller.messages.prepare_to_forward.wrote')}:
             \n\n#{old_message.body}"
  end

  def delete_replied
    m = Message.find params[:replied_id]
    ensure_ownership m
    m.update_attribute :folder, Message::TRASH
    logger.debug ':-) replied message sent to trash'
  end

  def save_sent
    m = @message.clone
    m.owner = logged_user
    m.folder = Message::SENT
    m.save
    logger.debug ':-) copy saved in sent folder'
  end
end





















