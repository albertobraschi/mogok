
class BgTask < ActiveRecord::Base

  validates_presence_of :name, :class_name

end
