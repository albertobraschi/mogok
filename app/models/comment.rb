
class Comment < ActiveRecord::Base
  strip_attributes! # strip_attributes
  
  belongs_to :user
  belongs_to :torrent  
  validates_presence_of :body

  def before_save
    self.body = self.body[0, 2000] if self.body
  end

  def editable_by?(user)
    user.id == self.user_id || user.admin_mod?
  end
end
