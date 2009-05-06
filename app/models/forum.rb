
class Forum < ActiveRecord::Base
  strip_attributes! # strip_attributes
  
  has_many :topics, :dependent => :destroy

  def editable_by?(user)
    user.admin?
  end

  def self.all
    find :all, :order => 'position'
  end
end
