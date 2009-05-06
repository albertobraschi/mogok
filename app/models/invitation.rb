
class Invitation < ActiveRecord::Base
  belongs_to :user
  
  validates_uniqueness_of :code

  def self.user_invitations(user)
    find_all_by_user_id user, :order => 'created_at DESC'
  end
end
