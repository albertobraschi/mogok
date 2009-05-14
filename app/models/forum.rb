
class Forum < ActiveRecord::Base
  strip_attributes! # strip_attributes
  
  has_many :topics, :dependent => :destroy

  def editable_by?(user)
    user.admin?
  end

  def self.all
    find :all, :order => 'position'
  end

  def add_topic(params, user)
    t = Topic.new :forum => self,
                  :user => user,
                  :title => params[:title],
                  :created_at => Time.now,
                  :last_post_at => Time.now

    t.topic_post = Post.new :user => user,
                            :topic => t,
                            :forum => self,
                            :post_number => 1,
                            :is_topic_post => true,
                            :created_at => Time.now,
                            :body => params[:body]
    Forum.transaction do
      t.save
      increment! :topics_count
    end
    t
  end


  def search(params, args)
    Topic.paginate_by_forum_id self,
                               :conditions => search_conditions(params),
                               :order => 'stuck DESC, last_post_at DESC',
                               :page => self.class.current_page(params[:page]),
                               :per_page => args[:per_page]
  end


  def self.search_all(params, args)
    Topic.paginate :conditions => search_all_conditions(params),
                   :order => 'last_post_at DESC',
                   :page => current_page(params[:page]),
                   :per_page => args[:per_page]
  end

  private


    def search_conditions(params)
      self.class.search_all_conditions params
    end

    def self.search_all_conditions(params)
      s, h = '', {}
      unless params[:keywords].blank?
        s << 'id IN (SELECT topic_id FROM topic_fulltexts WHERE MATCH(body) AGAINST (:keywords IN BOOLEAN MODE) ) '
        h[:keywords] = params[:keywords]
      end
      [s, h]
    end
end




