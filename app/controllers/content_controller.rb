
class ContentController < ApplicationController
  before_filter :login_required
  
  def index
    logger.debug ':-) content_controller.index'
  end
  
  def help
    logger.debug ':-) content_controller.help'
  end
  
  def staff
    logger.debug ':-) content_controller.staff'
  end
end
