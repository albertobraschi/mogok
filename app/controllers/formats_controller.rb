
class FormatsController < ApplicationController
  before_filter :login_required
  before_filter :admin_required
  cache_sweeper :domain_sweeper, :only => [:new, :edit, :destroy]
  
  def index
    @formats = Format.all
  end
  
  def new
    @format = Format.new params[:format]
    if request.post?
      if @format.save
        redirect_to :action => 'index'
      end      
    end
    @types = Type.find :all
  end
  
  def edit
    @format = Format.find params[:id]
    if request.post?      
      if @format.update_attributes params[:format]
        redirect_to :action => 'index'
      end      
    end
    @types = Type.find :all
  end
  
  def destroy
    if request.post?
      Format.destroy params[:id]
    end
    redirect_to :action => 'index'
  end
end