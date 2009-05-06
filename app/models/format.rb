
class Format < ActiveRecord::Base
  belongs_to :type
  has_many :torrents, :dependent => :nullify
  
  validates_presence_of :type_id, :name

  def self.all
    find :all, :order => 'type_id, name'
  end
end
