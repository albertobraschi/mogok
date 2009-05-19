
class RolesController < ApplicationController
  before_filter :logged_in_required
  before_filter :owner_required
  
  def index
    @roles = Role.find :all
  end
  
  def new
    @role = Role.new params[:role]
    if request.post?
      @role.name = params[:role][:name]
      if @role.save
        redirect_to :action => 'index'
      end      
    end
  end

  def edit
    @role = Role.find params[:id]
    if request.post?
      @role.name = params[:role][:name] unless @role.default?
      if @role.update_attributes params[:role]
        redirect_to :action => 'index'
      end
    end
  end
  
  def destroy
    if request.post?
      r = Role.find params[:id]
      unless User.scoped_by_role_id(r.id).find(:first)
        unless r.default?
          r.destroy
        else
          flash[:error] = 'role is required by the application'
        end
      else
        flash[:error] = 'role is in use'
      end
    end
    redirect_to :action => 'index'
  end
end