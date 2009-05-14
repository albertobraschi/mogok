
class Topic < ActiveRecord::Base
  strip_attributes! # strip_attributes

  has_one :topic_post, :class_name => 'Post', :conditions => {:is_topic_post => true}
  has_many :posts, :dependent => :destroy
  has_one :topic_fulltext, :dependent => :destroy
  belongs_to :user
  belongs_to :forum
  
  attr_accessor :last_post

  after_create :create_fulltext
  after_update :update_fulltext

  def editable_by?(user)
    user.id == self.user_id || user.admin_mod?
  end

  def edit(params, editor)
    self.title = params[:title]
    self.topic_post.body = params[:body]
    self.topic_post.edited_at = Time.now
    self.topic_post.edited_by = editor.username
    Topic.transaction do
      self.topic_post.save
      save
    end
  end

  def add_post(params, user)
    Topic.transaction do
      self.replies_count += 1
      self.last_post_at = Time.now
      self.last_post_by = user.username
      save
      p = Post.new :user => user, 
                   :topic => self,
                   :forum_id => self.forum_id,
                   :body => params[:body]
      p.post_number = self.replies_count + 1
      p.save
    end
  end

  def destroy
    Topic.transaction do
      self.forum.decrement! :topics_count if self.forum.topics_count > 0
      super
    end
  end

  def paginate_posts(params, args)
    Post.paginate_by_topic_id self,
                              :order => 'created_at',
                              :page => self.class.current_page(params[:page]),
                              :per_page => args[:per_page]
  end

  private

    def create_fulltext
      TopicFulltext.create :topic => self, :body => "#{self.title} #{self.topic_post.body}"
    end

    def update_fulltext
      self.topic_fulltext.update_attribute :body, "#{self.title} #{self.topic_post.body}"
    end
end
