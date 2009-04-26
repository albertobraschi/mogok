
class Snatch < ActiveRecord::Base
  belongs_to :torrent
  belongs_to :user
end
