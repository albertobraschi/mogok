
class Topic < ActiveRecord::Base
  strip_attributes! # strip_attributes plugin

  has_one :topic_post, :class_name => 'Post', :conditions => {:is_topic_post => true}
  has_many :posts, :dependent => :destroy
  has_one :topic_fulltext, :dependent => :destroy
  belongs_to :user
  belongs_to :forum
  
  attr_accessor :last_post

  after_create :create_fulltext
  after_update :update_fulltext


  def add_post(body, user)
    Topic.transaction do
      self.replies_count += 1
      self.last_post_at = Time.now
      self.last_post_by = user.username
      save
      Post.create :user => user,
                  :topic => self,
                  :forum_id => self.forum_id,
                  :body => body,
                  :post_number => self.replies_count + 1
    end
  end

  def destroy
    Topic.transaction do
      self.forum.decrement! :topics_count if self.forum.topics_count > 0
      super
    end
  end

  def report(reporter, reason, path)
    Report.create(self, reporter, reason, path)
  end

  def paginate_posts(params, args)
    Post.paginate_by_topic_id self,
                              :order => 'created_at',
                              :page => params[:page],
                              :per_page => args[:per_page]
  end

  def editable_by?(user)
    user.id == self.user_id || user.admin_mod?
  end

  def edit(title, body, editor)
    self.title = title
    self.topic_post.body = body
    self.topic_post.edited_at = Time.now
    self.topic_post.edited_by = editor.username
    Topic.transaction do
      self.topic_post.save
      save
    end
  end

  private

    def create_fulltext
      TopicFulltext.create :topic => self, :body => "#{self.title} #{self.topic_post.body}"
    end

    def update_fulltext
      self.topic_fulltext.update_attribute :body, "#{self.title} #{self.topic_post.body}"
    end
end
