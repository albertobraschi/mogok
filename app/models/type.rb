
class Type < ActiveRecord::Base
  extend CachingMethods

  has_many :formats, :dependent => :destroy, :order => :name
  has_many :categories, :dependent => :destroy, :order => :name
    
  validates_presence_of :name

  CACHED_ALL_KEY = 'types.all'

  def self.reset_cached_all
    expire_cached CACHED_ALL_KEY
    cached_all
  end

  def self.cached_all
    fetch_cached(CACHED_ALL_KEY) do
      find :all, :include => :formats
    end
  end
end
