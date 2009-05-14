
class ClientsController < ApplicationController
  before_filter :logged_in_required
  before_filter :admin_required
  
  def index
    @clients = Client.all
  end
  
  def new
    @client = Client.new params[:client]
    if request.post?
      if @client.save
        redirect_to :action => 'index'
      end      
    end
  end
  
  def edit
    @client = Client.find params[:id]
    if request.post?      
      if @client.update_attributes params[:client]
        redirect_to :action => 'index'
      end      
    end
  end
  
  def destroy
    if request.post?
      Client.destroy params[:id]
    end
    redirect_to :action => 'index'
  end
end