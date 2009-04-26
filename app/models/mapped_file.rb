
class MappedFile < ActiveRecord::Base
  extend CachingMethods

  belongs_to :torrent

  def self.expire_cached_by_torrent(t)
    expire_cached cached_by_torrent_key(t)
  end

  def self.cached_by_torrent(t)
    fetch_cached(cached_by_torrent_key(t)) do
      find :all, :conditions => {:torrent_id => t.id}, :order => :name
    end
  end

  def self.cached_by_torrent_key(t)
    "mapped_files.torrent.#{t.id}"
  end
end
