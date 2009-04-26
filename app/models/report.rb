
class Report < ActiveRecord::Base
  strip_attributes! # strip_attributes

  belongs_to :user
  belongs_to :handler, :class_name => 'User', :foreign_key => 'handler_id'

  def before_save
    self.reason = self.reason[0, 200]
  end
end
