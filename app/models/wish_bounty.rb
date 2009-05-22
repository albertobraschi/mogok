
class WishBounty < ActiveRecord::Base

  belongs_to :user
  belongs_to :wish

  before_create :new_bounty_routine
  before_destroy :destroy_bounty_routine

  validates_presence_of :amount

  def revoke
    WishBounty.transaction do
      self.user.lock!
      self.user.uploaded += self.amount
      self.user.save

      self.wish.lock!
      self.wish.total_bounty -= self.amount
      self.wish.save

      self.revoked = true
      save
    end
  end

  private

    def new_bounty_routine
      self.user.lock!
      self.user.uploaded -= self.amount
      self.user.save

      self.wish.lock!
      self.wish.increment :bounties_count
      self.wish.total_bounty += self.amount
      self.wish.save

      self.bounty_number = self.wish.bounties_count
    end

    def destroy_bounty_routine
      if !revoked? && !self.wish.filled?
        self.user.lock!
        self.user.uploaded += self.amount
        self.user.save
      end
    end
end
