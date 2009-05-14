
class CountriesController < ApplicationController
  before_filter :logged_in_required
  before_filter :admin_required
  cache_sweeper :domain_sweeper, :only => [:new, :edit, :destroy]

  def index
    @countries = Country.all
  end

  def new
    @country = Country.new params[:country]
    if request.post?
      if @country.save
        redirect_to :action => 'index'
      end
    end
  end

  def edit
    @country = Country.find params[:id]
    if request.post?      
      if @country.update_attributes params[:country]
        redirect_to :action => 'index'
      end
    end
  end

  def destroy
    if request.post?
      Country.destroy params[:id]
    end
    redirect_to :action => 'index'
  end
end