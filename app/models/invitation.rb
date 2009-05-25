
class Invitation < ActiveRecord::Base
  belongs_to :user
  
  validates_uniqueness_of :code

  def self.create(code, inviter, email)
    super :code => code, :user => inviter, :email => email
  end
end
