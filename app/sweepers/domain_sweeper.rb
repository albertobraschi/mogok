
class DomainSweeper < ActionController::Caching::Sweeper
  observe Type, Format, Category, Tag, Country, Style, Gender

  def after_save(r)
    expire_domain_cache r
  end

  def after_destroy(r)
    expire_domain_cache r
  end

  private
  
    def expire_domain_cache(r)
      logger.debug ":-) domain_sweeper.expire_domain_cache: r is a #{r.class}" if logger
      case r
      when Type
        Type.reset_cached_all
      when Format
        Type.reset_cached_all
      when Category
        Category.reset_cached_all
      when Tag
        Category.reset_cached_all
      when Country
        Country.reset_cached_all
      when Style
        Style.reset_cached_all
        skip_fragment_expiration = true
      when Gender
        Gender.reset_cached_all
        skip_fragment_expiration = true
      end

      unless skip_fragment_expiration
        expire_fragment(:controller => 'torrents', :action => 'index', :partial_name => 'index_search_box')
      end
    end
end