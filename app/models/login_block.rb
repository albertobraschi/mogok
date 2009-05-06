
class LoginBlock < ActiveRecord::Base

  def self.all
    find :all, :order => 'blocks_count DESC'
  end
end
