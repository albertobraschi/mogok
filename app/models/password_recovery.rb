
class PasswordRecovery < ActiveRecord::Base
  belongs_to :user
  
  validates_uniqueness_of :code

  def self.delete_all_by_user(user)
    delete_all ['user_id = ?', user.id]
  end

  def self.create(user, code)
    super :user => user, :code => code
  end

  def self.delete_olds(threshold)
    delete_all ['created_at < ?', threshold]
  end
end
