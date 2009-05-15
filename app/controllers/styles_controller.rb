
class StylesController < ApplicationController
  before_filter :login_required
  before_filter :admin_required
  cache_sweeper :domain_sweeper, :only => [:new, :edit, :destroy]

  def index
    @styles = Style.all
  end

  def new
    @style = Style.new params[:style]
    if request.post?
      if @style.save
        redirect_to :action => 'index'
      end
    end
  end

  def edit
    @style = Style.find params[:id]
    if request.post?      
      if @style.update_attributes params[:style]
        redirect_to :action => 'index'
      end
    end
  end

  def destroy
    if request.post?
      s = Style.find params[:id]
      Style.transaction do
        s.destroy
        User.scoped_by_style_id(s.id).find(:all).each do |u|
          u.update_attribute :style_id, 1
        end
      end
    end
    redirect_to :action => 'index'
  end
end