
class RawInfo < ActiveRecord::Base
  belongs_to :torrent

  index [:torrent_id] #cache_money
end
