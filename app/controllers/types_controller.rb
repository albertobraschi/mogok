
class TypesController < ApplicationController
  before_filter :logged_in_required
  before_filter :admin_required
  cache_sweeper :domain_sweeper, :only => [:new, :edit, :destroy]
  
  def index
    @types = Type.find :all
  end
  
  def new
    @type = Type.new params[:type]
    if request.post?
      if @type.save
        redirect_to :action => 'index'
      end
    end
  end
  
  def edit
    @type = Type.find params[:id]
    if request.post?
      if @type.update_attributes params[:type]
        redirect_to :action => 'index'
      end
    end
  end
  
  def destroy
    if request.post?
      t = Type.find params[:id]
      in_use = false
      t.categories.each do |c|
        in_use = true if Torrent.scoped_by_category_id(c.id).find(:first)
      end
      unless in_use
        t.destroy
      else
        flash[:error] = 'type is in use'
      end
    end
    redirect_to :action => 'index'
  end
end