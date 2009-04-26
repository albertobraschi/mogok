
class TagsController < ApplicationController
  before_filter :login_required
  before_filter :admin_required
  cache_sweeper :domain_sweeper, :only => [:new, :edit, :destroy]
  
  def index
    conditions = {:category_id => params[:category_filter]} unless params[:category_filter].blank?
    @tags = Tag.find :all, :conditions => conditions, :order => 'category_id, name'
    @categories = Category.find :all, :order => 'position'
  end
  
  def new
    @tag = Tag.new params[:tag]    
    if request.post?
      if @tag.save
        redirect_to :action => 'index', :category_filter => params[:category_filter]
      end
    end
    @categories = Category.find :all
    @tag.category_id = params[:category_filter].to_i if params[:category_filter]
  end
  
  def edit
    @tag = Tag.find params[:id]
    if request.post?
      if @tag.update_attributes params[:tag]
        redirect_to :action => 'index', :category_filter => params[:category_filter]
      end
    end      
    @categories = Category.find :all
  end
  
  def destroy
    if request.post?
      Tag.destroy params[:id]      
    end
    redirect_to :action => 'index', :category_filter => params[:category_filter]
  end
end