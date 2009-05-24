
class WishBountiesController < ApplicationController
  before_filter :logged_in_required

  def index
    logger.debug ':-) wish_bounties_controller.index'
    @wish = Wish.find params[:wish_id]
    @wish_bounties = @wish.paginate_bounties params, :per_page => APP_CONFIG[:page_size][:wish_bounties]    
  end

  def new
    logger.debug ':-) wish_bounties_controller.new'
    @wish = Wish.find params[:wish_id]
    access_denied unless @wish.open?
    if request.post?
      unless cancelled?
        bounty_amount = parse_bounty_amount
        if bounty_amount
          if current_user.uploaded >= bounty_amount
            @wish.add_bounty bounty_amount, current_user
            flash[:notice] = t('success')
            redirect_to wish_bounties_path(:wish_id => @wish, :page => 'last')
          else
            logger.debug ':-o insufficient upload credit'
            flash.now[:error] = t('insufficient_upload_credit')
          end
        else
          logger.debug ':-o bounty amount parse error'
          flash.now[:error] = t('invalid_bounty_amount')
        end
      else
        redirect_to wish_bounties_path(:action => 'index', :wish_id => @wish)
      end
    end
  end

  def revoke
    logger.debug ':-) wish_bounties_controller.destroy'
    @wish_bounty = WishBounty.find params[:id]
    access_denied if @wish_bounty.revoked? || !@wish_bounty.wish.open?
    if request.post?
      unless cancelled?
        @wish_bounty.revoke
        flash[:notice] = t('success')
      end
      redirect_to wish_bounties_path(:action => 'index', :wish_id => @wish_bounty.wish)
    end
  end

  private

    def parse_bounty_amount
      unless params[:bounty_amount].blank?
        begin
          a = Integer(params[:bounty_amount])
        rescue
          return nil
        end
        if params[:bounty_unit] == 'MB'
          a = a.megabytes
        elsif params[:bounty_unit] == 'GB'
          a = a.gigabytes
        else
          raise ArgumentError.new('invalid bounty unit')
        end
      end
      a
    end
end















