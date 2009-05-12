
class Invitation < ActiveRecord::Base
  belongs_to :user
  
  validates_uniqueness_of :code

  def self.create(code, user, email)
    super :code => code, :user => user, :email => email, :created_at => Time.now
  end
end
