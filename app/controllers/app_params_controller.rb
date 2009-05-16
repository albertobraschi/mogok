
class AppParamsController < ApplicationController
  before_filter :logged_in_required
  before_filter :admin_required, :only => [:index, :new, :edit]
  before_filter :owner_required, :only => :destroy

  def index
    @app_params = AppParam.find :all
  end

  def new
    @app_param = AppParam.new params[:app_param]
    if request.post?
      if @app_param.save
        redirect_to :action => 'index'
      end
    end
  end

  def edit
    @app_param = AppParam.find params[:id]
    if request.post?      
      if @app_param.update_attributes params[:app_param]
        redirect_to :action => 'index'
      end
    end
  end

  def destroy
    if request.post?
      AppParam.destroy params[:id]
    end
    redirect_to :action => 'index'
  end
end