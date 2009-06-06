
class Reward < ActiveRecord::Base

  belongs_to :user
  belongs_to :torrent

  before_create :new_reward_routine

  validates_presence_of :amount

  private

    def new_reward_routine
      self.user.charge! self.amount

      self.torrent.user.credit! self.amount

      self.torrent.lock!
      self.torrent.total_reward += self.amount
      self.torrent.increment :rewards_count
      self.torrent.save
      
      self.reward_number = self.torrent.rewards_count
    end
end
