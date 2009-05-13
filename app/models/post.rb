
class Post < ActiveRecord::Base
  strip_attributes! # strip_attributes

  belongs_to :topic
  belongs_to :forum
  belongs_to :user

  before_save :trim_body

  def editable_by?(user)
    user.id == self.user_id || user.admin_mod?
  end

  def edit(params, editor)
    self.body = params[:body]
    self.edited_at = Time.now
    self.edited_by = editor.username
    save
  end

  private
  
  def trim_body
    limit = self.is_topic_post ? 10000 : 4000
    self.body = self.body[0, limit] if self.body
  end
end
