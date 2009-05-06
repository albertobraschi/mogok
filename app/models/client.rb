
class Client < ActiveRecord::Base
  attr_accessor :banned_version
  attr_reader :version

  index [:code] # cache_money

  validates_presence_of :code, :name
  
  def banned_version?
    self.banned_version == true
  end

  def version=(version)
    @version = version
    if self.min_version && self.min_version > version.to_i 
      self.banned_version = true
    end
  end

  def self.all
    find :all, :order => 'name'
  end
end
