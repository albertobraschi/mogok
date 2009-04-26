
class LoginBlocksController < ApplicationController
  before_filter :login_required
  before_filter :admin_required

  def index
    @login_blocks = LoginBlock.find :all, :order => 'blocks_count DESC'
  end

  def destroy
    if request.post?
      LoginBlock.destroy params[:id]
    end
    redirect_to :action => 'index'
  end

  def clear_all
    if request.post?
      LoginBlock.delete_all
    end
    redirect_to :action => 'index'
  end
end