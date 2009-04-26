
class Category < ActiveRecord::Base
  extend CachingMethods

  belongs_to :type
  has_many :tags, :dependent => :destroy, :order => :name
  has_many :torrents

  validates_presence_of :type_id, :name

  CACHED_ALL_KEY = 'categories.all'

  def self.reset_cached_all
    expire_cached CACHED_ALL_KEY
    cached_all
  end

  def self.cached_all
    fetch_cached(CACHED_ALL_KEY) do
      find :all, :order => 'position', :include => :tags
    end
  end
end
