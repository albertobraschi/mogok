
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

  def self.search(params, *args)
    options = args.pop
    paginate :conditions => search_conditions(params),
             :order => 'last_post_at DESC',
             :page => current_page(params[:page]),
             :per_page => options[:per_page]
  end

  def self.search_by_forum(forum, params, *args)
    options = args.pop
    paginate_by_forum_id forum,
                         :conditions => search_conditions(params),
                         :order => 'stuck DESC, last_post_at DESC',
                         :page => current_page(params[:page]),
                         :per_page => options[:per_page]
  end

  private

  def self.search_conditions(params)
    s, h = '', {}
    unless params[:keywords].blank?
      s << 'id IN (SELECT topic_id FROM topic_fulltexts WHERE MATCH(body) AGAINST (:keywords IN BOOLEAN MODE) ) '
      h[:keywords] = params[:keywords]
    end
    [s, h]
  end
end
