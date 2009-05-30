
class Country < ActiveRecord::Base
  extend CachingMethods

  has_many :users, :dependent => :nullify
  has_many :torrents, :dependent => :nullify

  validates_presence_of :name

  CACHED_ALL_KEY = 'countries.all'

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
