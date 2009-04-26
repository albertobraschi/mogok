
class PeerConn < ActiveRecord::Base
  has_many :peers

  index [:ip, :port] #cache_money
end
