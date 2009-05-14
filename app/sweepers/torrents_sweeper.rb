
class TorrentsSweeper < ActionController::Caching::Sweeper
  observe Torrent

  def after_create(r)
    logger.debug ':-) torrents_sweeper.after_create' if logger
    expire_fragment_cache
  end

  def after_update(r)
    logger.debug ':-) torrents_sweeper.after_update' if logger
    expire_fragment_cache if r.inactivated?
  end

  def after_destroy(r)
    logger.debug ':-) torrents_sweeper.after_destroy' if logger
    MappedFile.expire_cached_by_torrent(r)
    expire_fragment_cache
  end

  private
  
    def expire_fragment_cache
      logger.debug ':-) torrents_sweeper.expire_fragment_cache' if logger
      5.times do |i|
        expire_timed_fragment("torrents.index.page.#{i + 1}", true) # expires only the first five pages
      end
    end
end
