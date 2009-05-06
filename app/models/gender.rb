
class Gender < ActiveRecord::Base
  extend CachingMethods
  
  has_many :users, :dependent => :nullify

  CACHED_ALL_KEY = 'genders.all'

  def self.reset_cached_all
    expire_cached CACHED_ALL_KEY
    cached_all
  end

  def self.cached_all
    fetch_cached(CACHED_ALL_KEY) do
      find :all, :order => 'name'
    end
  end

  def self.all
    find :all, :order => 'name'
  end
end
