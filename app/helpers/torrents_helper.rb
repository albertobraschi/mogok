
module TorrentsHelper

  def torrent_link(t, format = nil, text_limit = nil)
    html_options = {}

    case format
      when :browse
        html_options[:class] = 'torrent'
        if !t.active?
          html_options[:class] << ' torrent_inactive'
        elsif t.seeders_count == 0
          html_options[:class] << ' torrent_dead'
        end
      when :compact
        html_options[:class] = 'torrent_compact'
    end
    
    if text_limit
      text = truncate(t.name, :length => text_limit)
      html_options[:title] = t.name if t.name.size > text_limit
    else
      text = t.name
    end
    link_to text, {:controller => 'torrents', :action => 'show', :id => t}, html_options
  end

  def torrent_download_link(t, text_link = false)
    if text_link
      text = TorrentsHelper.torrent_file_name t
    else
      text = image_tag('download.png', :alt => 'Download', :title => t('helper.torrents_helper.torrent_download_link.download'))
    end
    link_to text, {:controller => 'torrents', :action => 'download', :id => t}, {:onclick => 'this.blur();'}
  end

  def self.torrent_file_name(t, prefix = nil)
    s = ''
    s << "[#{ prefix }] " if prefix
    s << t.name[0, 40].gsub(/[^\w\-\s]/, '')
    s << '.torrent'
  end

  def torrent_additional_info(t, new_torrent_threshold_time = nil)
    s = ''
    if new_torrent_threshold_time && (t.created_at + new_torrent_threshold_time.minutes > Time.now)
      s << content_tag('span', 'new', :class => 'torrent_new_label')
      previous = true
    end
    if t.format
      s << ' | ' if previous
      s << t.format.name.downcase
      previous = true
    end
    if t.country
      s << ' | ' if previous
      s << t.country.name
      previous = true
    end
    if t.year
      s << ' | ' if previous
      s << t.year.to_s
    end
    css_class = t.seeders_count > 0 ? 'torrent_info' : 'torrent_dead_info'
    s.blank? ? nil : content_tag('span', "[ #{s} ]", :class => css_class)
  end

  def bookmark_link_text(t, spinner_id)
    span = bookmark_span t, bookmark_text(t)
    link_to_remote span,
                   :url => {:controller => 'torrents', :action => 'bookmark', :id => t, :text_link => '1'},
                   :before => "this.blur();hide_show_div('#{spinner_id}', 'spinner_right')",
                   :complete => "hide_show_div('#{spinner_id}')"
  end

  def bookmark_link_image(t)
    span = bookmark_span t, bookmark_image(t)
    link_to_remote span,
                   :url => {:controller => 'torrents', :action => 'bookmark', :id => t},
                   :before => "this.blur();replace_with_spinner('#{bookmark_span_id(t)}', '#{path_to_image('spinner.gif')}')"
  end

  def bookmark_span(t, content)
    content_tag('span', content, :id => bookmark_span_id(t))
  end

  def bookmark_span_id(t)
    "bookmark_span_#{t.id}"
  end

  def bookmark_text(t)
    t.bookmarked? ? 'unbookmark' : 'bookmark'
  end

  def bookmark_image(t)
    t.bookmarked? ? image_tag('unbookmark.png', :class => 'bookmark', :title => t('helper.torrents_helper.bookmark_image.unbookmark')) :
                    image_tag('bookmark.png', :class => 'bookmark', :title => t('helper.torrents_helper.bookmark_image.bookmark'))
  end

  def category_label(c, params = nil, link = false)
    text = c.image ? image_tag(c.image, :class => 'torrent_category', :alt => c.name, :title => c.name) : c.name
    if link && params
      link_params = params.dup
      link_params.delete_if {|k, v| v.blank? } # just to clean the link
      link_params[:category_id] = c.id
      link_to text, link_params
    else
      text
    end    
  end

  def advanced_fields_class(params)
    a = [params[:category_id], params[:format_id], params[:tags_str], params[:country_id], params[:inactive]]
    a.reject! {|e| e.blank? }
    a.blank? ? 'hide' : ''
  end
  
  def tags_links(tags, params, link_css_class, container_css_class)
    link_params = params.dup
    link_params[:page] = nil
    link_params.delete_if {|k, v| v.blank? } # just to clean the link    
    html = ''
    tags.each do |t|
      link_params[:tags_str] = t.name
      link_params[:category_id] = t.category_id
      html << link_to(t.name, link_params, :class => link_css_class)
      html << ', ' unless t == tags.last
    end if tags
    html.blank? ? nil : content_tag('div', html, :class => container_css_class)
  end

  def populate_tags_formats_script(categories, types)
    s =  "     <script type='text/javascript'>\n"
    s << "       <!--\n"

    s << "       var categories_types = new Array();"
    categories.each do |c|
      s << "     categories_types[#{c.id}] = #{c.type_id};"
    end

    s << "       var types_formats = new Array();"
    types.each do |t|
      if t.formats.blank?
        s << "   types_formats[#{t.id}] = null;"
      else
        s << "   var formats = new Array();"
        t.formats.each_with_index do |f, i|
          s << " formats[#{i}] = new Array(#{f.id}, '#{f.name}');"
        end
        s << "   types_formats[#{t.id}] = formats;"
      end
    end

    s << "       var categories_tags = new Array();"
    categories.each do |c|
      if c.tags.blank?
        s << "   categories_tags[#{c.id}] = null;"
      else
        s << "   var tags = new Array();"
        c.tags.each_with_index do |t, i|
          s << " tags[#{i}] = new Array('#{t.name}', '#{t.name}');"
        end
        s << "   categories_tags[#{c.id}] = tags;"
      end
    end

    s << "       function populate_formats(self) {"
    s << "         var selected_cat = self.options[self.selectedIndex].value;"
    s << "         var target = $('format_id');"
    s << "         var formats = types_formats[categories_types[selected_cat]];"
    s << "         populate_select(target, formats, 1)"
    s << "       }"

    s << "       function populate_tags(self) {"
    s << "         var selected_cat = self.options[self.selectedIndex].value;"
    s << "         var target = $('tags_select');"
    s << "         var tags = categories_tags[selected_cat];"
    s << "         populate_select(target, tags, 1);"
    s << "       }"

    s << "       //-->\n"
    s << "     </script>"
  end
end
