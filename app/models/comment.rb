
class Comment < ActiveRecord::Base
  strip_attributes! # strip_attributes plugin
  
  belongs_to :user
  belongs_to :torrent

  before_save :trim_body

  validates_presence_of :body

  def report(reporter, reason, path)
    Report.create(self, reporter, reason, path)
  end

  def editable_by?(user)
    user.id == self.user_id || user.admin_mod?
  end

  def edit(body, editor)
    self.body = body
    self.edited_at = Time.now
    self.edited_by = editor.username
    save
  end

  private

    def trim_body
      self.body = self.body[0, 2000] if self.body
    end
end
