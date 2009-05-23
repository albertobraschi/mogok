
class InvitationsController < ApplicationController
  before_filter :set_mailer_host, :only => :new
  before_filter :logged_in_required
    
  def index
    logger.debug ':-) invitations_controller.index'
    ticket_required :inviter
    @app_params = AppParam.params_hash
    @invitations = current_user.invitations
    @invitees = current_user.paginate_invitees params, :per_page => APP_CONFIG[:page_size][:users]
  end
  
  def new
    logger.debug ':-) invitations_controller.new'
    @app_params = AppParam.params_hash
    access_denied if !@app_params[:signup_open] && !current_user.admin?
    ticket_required :inviter
    if request.post?
      unless cancelled?
        email = params[:email] = HtmlHelper.sanitize(params[:email])
        if User.valid_email? email
          if User.find_by_email(email) || Invitation.find_by_email(email)
            flash.now[:error] = t('email_in_use')
          else
            code = User.make_invite_code
            begin
              AppMailer.deliver_invitation email, current_user, code
            rescue => e
              log_error e
              flash.now[:error] = t('delivery_error')
              return
            end
            Invitation.create code, current_user, email
            flash[:notice] = t('success', :email => email)
            redirect_to :action => 'index'
          end
        else
          flash.now[:error] = t('invalid_email')
        end
      else
        redirect_to :action => 'index'
      end
    end
  end
  
  def destroy
    logger.debug ':-) invitations_controller.destroy'
    if request.post?
      i = Invitation.find params[:id]
      access_denied if i.user_id != current_user.id
      i.destroy
      flash[:notice] = t('success')
    end
    redirect_to :action => 'index'
  end

  private

    def set_mailer_host
      AppMailer.default_url_options[:host] = request.host_with_port
    end
end
