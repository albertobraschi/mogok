
class Invitation < ActiveRecord::Base
  belongs_to :user
  
  validates_uniqueness_of :code
end
