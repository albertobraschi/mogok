
class RewardsController < ApplicationController
  before_filter :logged_in_required

  def index
    logger.debug ':-) rewards_controller.index'
    @torrent = Torrent.find params[:torrent_id]
    @rewards = @torrent.paginate_rewards params, :per_page => APP_CONFIG[:page_size][:rewards]
  end

  def new
    logger.debug ':-) rewards_controller.new'
    @torrent = Torrent.find params[:torrent_id]
    access_denied if @torrent.user == current_user
    if request.post?
      unless cancelled?
        reward_amount = parse_reward_amount
        if reward_amount
          if current_user.uploaded > reward_amount
            @torrent.add_reward reward_amount, current_user
            flash[:notice] = t('success')
            redirect_to rewards_path(:torrent_id => @torrent, :page => 'last')
          else
            flash.now[:error] = t('insuficient_upload_credit')
          end
        else
          flash.now[:error] = t('invalid_reward_amount')
        end
      else
        redirect_to rewards_path(:action => 'index', :torrent_id => @torrent)
      end
    end
  end

  private

    def parse_reward_amount
      unless params[:reward_amount].blank?
        begin
          a = Integer(params[:reward_amount])
        rescue
          return nil
        end

        if params[:reward_unit] == 'MB'
          a = a.megabytes
        elsif params[:reward_unit] == 'GB'
          a = a.gigabytes
        else
          raise ArgumentError.new('invalid reward unit')
        end
      end
      a
    end
end















