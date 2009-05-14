
class CategoriesController < ApplicationController
  before_filter :logged_in_required
  before_filter :admin_required
  cache_sweeper :domain_sweeper, :only => [:new, :edit, :destroy]
  
  def index
    @categories = Category.all
  end
  
  def new
    @category = Category.new params[:category]
    if request.post?
      if @category.save
        redirect_to :action => 'index'
      end      
    end
    @types = Type.find :all
  end
  
  def edit
    @category = Category.find params[:id]
    if request.post?      
      if @category.update_attributes params[:category]
        redirect_to :action => 'index'
      end      
    end
    @types = Type.find :all
  end
  
  def destroy    
    if request.post?
      c = Category.find params[:id]
      unless Torrent.scoped_by_category_id(c.id).find(:first)
        c.destroy
      else
        flash[:error] = 'category is in use'
      end
    end
    redirect_to :action => 'index'
  end
end