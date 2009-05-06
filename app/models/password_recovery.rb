
class PasswordRecovery < ActiveRecord::Base
  belongs_to :user
  
  validates_uniqueness_of :code

  def self.delete_all_by_user(user)
    delete_all ['user_id = ?', user.id]
  end
end
