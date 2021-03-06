
class Style < ActiveRecord::Base
  extend CachingMethods

  CACHED_ALL_KEY = 'styles.all'

  before_destroy :ensure_not_default

  validates_presence_of :name, :stylesheet

  def self.reset_cached_all
    expire_cached CACHED_ALL_KEY
    cached_all
  end

  def self.cached_all
    fetch_cached(CACHED_ALL_KEY) do
      find :all, :order => :name
    end
  end

  def self.all
    find :all, :order => 'name'
  end

  protected

    def ensure_not_default
      raise ArgumentError if self.id == 1
    end
end
