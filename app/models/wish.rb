
class Wish < ActiveRecord::Base
  concerns :callbacks, :finders, :validation

  strip_attributes! # strip_attributes

  has_many :wish_bounties, :dependent => :destroy
  has_one :wish_fulltext, :dependent => :destroy
  belongs_to :user
  belongs_to :filler, :class_name => 'User'
  belongs_to :category
  belongs_to :format
  belongs_to :country

  def add_comment(params, user)
    Wish.transaction do
      increment! :comments_count
      WishComment.create :user => user,
                         :wish => self,
                         :body => params[:body],
                         :comment_number => self.comments_count
    end
  end

  def add_bounty(amount, user)
    WishBounty.create :user => user,
                      :wish => self,
                      :amount => amount
  end

  def editable_by?(user)
    user.id == self.user_id || user.admin_mod?
  end

  def edit(params)
    set_attributes params
    save
  end

  private

    def set_attributes(params)
      if self.name != params[:name]
        self.name = params[:name]
        @update_fulltext = true
      end
      self.category_id = params[:category_id]
      self.format_id = params[:format_id]
      if self.description != params[:description]
        self.description = params[:description]
        @update_fulltext = true
      end
      self.year = params[:year]
      self.country_id = params[:country_id]
    end
end

