
class InvitationsController < ApplicationController
  before_filter :set_mailer_host, :only => :new
  before_filter :login_required
    
  def index
    logger.debug ':-) invitations_controller.index'
    ticket_required(:inviter)
    @app_params = AppParam.load
    @invitations = Invitation.user_invitations logged_user
    @invitees = User.user_invitees logged_user, params, :per_page => APP_CONFIG[:users_page_size]
  end
  
  def new
    logger.debug ':-) invitations_controller.new'
    @app_params = AppParam.load
    access_denied if !@app_params[:signup_open] && !logged_user.admin?
    ticket_required(:inviter)
    if request.post?
      unless cancelled?
        email = params[:email] = HtmlHelper.sanitize(params[:email])
        if User.valid_email? email
          if User.find_by_email(email) || Invitation.find_by_email(email)
            flash[:error] = t('controller.invitations.new.email_in_use')
          else
            code = User.make_invite_code
            begin
              AppMailer.deliver_invitation email, logged_user, code
              Invitation.create :created_at => Time.now, :code => code, :user_id => logged_user.id, :email => email
              flash[:notice] = t('controller.invitations.new.success', :email => email)
              redirect_to :action => 'index'
            rescue => e
              log_error e
              flash.now[:error] = t('controller.invitations.new.delivery_error')
            end
          end
        else
          flash[:error] = t('controller.invitations.new.invalid_email')
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
      access_denied if i.user_id != logged_user.id
      i.destroy
      flash[:notice] = t('controller.invitations.destroy.success')
    end
    redirect_to :action => 'index'
  end

  private

  def set_mailer_host
    AppMailer.default_url_options[:host] = request.host_with_port
  end
end
