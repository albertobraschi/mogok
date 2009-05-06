
class BgTask < ActiveRecord::Base

  validates_presence_of :name, :class_name

  def self.all
    find :all, :order => 'name'
  end
end
