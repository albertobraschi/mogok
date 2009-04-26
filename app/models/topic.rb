
class Topic < ActiveRecord::Base
  strip_attributes! # strip_attributes

  has_one :topic_post, :class_name => 'Post', :conditions => {:is_topic_post => true}
  has_many :posts, :dependent => :destroy
  has_one :topic_fulltext, :dependent => :destroy
  belongs_to :user
  belongs_to :forum
  
  attr_accessor :last_post

  def after_create
    TopicFulltext.create :topic_id => self.id, :body => "#{self.title} #{self.topic_post.body}"
  end

  def after_update
    self.topic_fulltext.update_attribute :body, "#{self.title} #{self.topic_post.body}"
  end

  def editable_by?(user)
    user.id == self.user_id || user.admin_mod?
  end
end
