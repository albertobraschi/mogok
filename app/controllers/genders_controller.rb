
class GendersController < ApplicationController
  before_filter :login_required
  before_filter :admin_required
  cache_sweeper :domain_sweeper, :only => [:new, :edit, :destroy]

  def index
    @genders = Gender.find :all, :order => 'name'
  end

  def new
    @gender = Gender.new params[:gender]
    if request.post?
      if @gender.save
        redirect_to :action => 'index'
      end
    end
  end

  def edit
    @gender = Gender.find params[:id]
    if request.post?
      if @gender.update_attributes params[:gender]
        redirect_to :action => 'index'
      end
    end
  end

  def destroy
    if request.post?
      Gender.destroy params[:id]
    end
    redirect_to :action => 'index'
  end
end