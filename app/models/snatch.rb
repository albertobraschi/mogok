
class Snatch < ActiveRecord::Base
  belongs_to :torrent
  belongs_to :user

  def self.user_snatches(user, params, *args)
    options = args.pop
    paginate_by_user_id user,
                        :order => 'created_at DESC',
                        :page => current_page(params[:page]),
                        :per_page => options[:per_page]
  end

  def self.torrent_snatches(torrent_id, params, *args)
    options = args.pop
    paginate_by_torrent_id torrent_id,
                           :order => 'created_at DESC',
                           :page => current_page(params[:page]),
                           :per_page => options[:per_page]
  end
end
