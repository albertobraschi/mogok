
class Post < ActiveRecord::Base
  strip_attributes! # strip_attributes

  belongs_to :topic
  belongs_to :forum
  belongs_to :user

  def before_save
    limit = self.is_topic_post ? 10000 : 4000
    self.body = self.body[0, limit] if self.body
  end
  
  def editable_by?(user)
    user.id == self.user_id || user.admin_mod?
  end

  def self.topic_posts(topic, params, args)
    paginate_by_topic_id topic,
                         :order => 'created_at',
                         :page => current_page(params[:page]),
                         :per_page => args[:per_page]
  end
end
