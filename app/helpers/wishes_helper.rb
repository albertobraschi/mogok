
module WishesHelper

  def wish_link(w, format = nil)
    html_options = {}

    case format
      when :browse
        html_options[:class] = 'torrent'
      when :compact
        html_options[:class] = 'torrent_compact'
    end

    link_to w.name, wishes_path(:action => 'show', :id => w), html_options
  end

  def wish_additional_info(w)
    s = ''
    if w.format
      s << w.format.name.downcase
      previous = true
    end
    if w.country
      s << ' | ' if previous
      s << w.country.name
      previous = true
    end
    if w.year
      s << ' | ' if previous
      s << w.year.to_s
    end
    s.blank? ? nil : content_tag('span', "[ #{s} ]", :class => 'wish_info')
  end

  def wishes_search_advanced_fields_class(params)
    a = [params[:category_id], params[:format_id], params[:country_id], params[:unfilled]]
    a.reject! {|e| e.blank? }
    a.blank? ? 'hide' : ''
  end

  def populate_formats_script(categories, types)
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

    s << "       function populate_formats(self) {"
    s << "         var selected_cat = self.options[self.selectedIndex].value;"
    s << "         var target = $('format_id');"
    s << "         var formats = types_formats[categories_types[selected_cat]];"
    s << "         populate_select(target, formats, 1)"
    s << "       }"

    s << "       //-->\n"
    s << "     </script>"
  end
end
