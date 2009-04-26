
module WillPaginate
  
  module ViewHelpers

    HEADER_CSS_CLASS = 'header'
    HEADER_ORDER_BY_CSS_CLASS = 'header_order_by'
    HEADER_LINK_CSS_CLASS = 'header'

    def table_header_css_class(column_name, collection)
      collection.blank? || (collection.order_by != column_name) ? HEADER_CSS_CLASS : HEADER_ORDER_BY_CSS_CLASS
    end    

    def table_header_link(text, column_name, collection)
      link_params = params.dup      
      if column_name == params[:order_by]
        desc = true unless params[:desc] == '1'
      else
        if collection && !collection.desc_by_default.blank?
          desc = true if collection.desc_by_default.include? column_name
        end
      end
      link_params[:desc] = desc ? '1' : nil
      link_params[:order_by] = column_name
      
      params[:page] = nil if params[:page] == '1' # just cosmetic
      link_params.delete_if {|k, v| v.blank? } # just cosmetic
      
      link_to text, link_params, {:class => HEADER_LINK_CSS_CLASS}
    end

    def will_paginate_remote(collection = nil, options = {}, remote_options = nil)
      options, collection = collection, nil if collection.is_a? Hash
      return nil unless WillPaginate::ViewHelpers.total_pages_for_collection(collection) > 1      
      options = options.symbolize_keys.reverse_merge WillPaginate::ViewHelpers.pagination_options
      renderer = case options[:renderer]
      when String
        options[:renderer].to_s.constantize.new
      when Class
        options[:renderer].new
      else
        options[:renderer]
      end
      renderer.prepare collection, options, self, remote_options
      renderer.to_html
    end    
  end

  # custom and OPTIONAL link renderer
  class MogokLinkRenderer

    class PaginationItem
      attr_accessor :text, :page, :link

      def initialize(text, page = nil)
        self.text = text
        self.page = page
      end
      
      def link?
        self.page != nil
      end
      
      def out(template, remote_options = nil)
        template.params[:page] = (self.page != 1) ? self.page : nil
        if link?
          template.params.delete_if {|k, v| v.blank? } # just cosmetic
          unless remote_options
            return template.link_to(self.text, template.params)
          else
            return template.link_to_remote(self.text,
                                           :url => template.url_for(template.params),
                                           :before => "this.blur();hide_show_div('#{remote_options[:spinner_id]}', '#{remote_options[:spinner_class]}')",
                                           :complete => "hide_show_div('#{remote_options[:spinner_id]}')")
          end
        else
          self.text
        end
      end
    end
    
    GAP = PaginationItem.new('&nbsp;|&nbsp;&nbsp;...&nbsp;&nbsp;|&nbsp;')
    SEPARATOR = PaginationItem.new('&nbsp;|&nbsp;')
    
    def prepare(collection, options, template, remote_options = nil)
      @collection = collection
      @options = options
      @remote_options = remote_options
      @template = template
      @template.params[:anchor] = @collection.html_anchor if @collection.html_anchor
    end
        
    # return the html links inside a div (just links if options[:container] is false)
    def to_html
      setup unless @items
      html = ''
      @items.each {|i| html << i.out(@template, @remote_options) }
      if @options[:container] 
        html = @template.content_tag :div, html, {:class => @options[:class]}
      end
      @template.params[:page] = @collection.current_page # reset page to current_page
      html
    end    
    
    private

    def setup()
      return if @collection.per_page >= @collection.total_entries
      @items = []
      current_page = @collection.current_page      
      num_pages = (@collection.total_entries / @collection.per_page.to_f).ceil
      rest = @collection.total_entries % @collection.per_page
      if num_pages <= 11
        make_items(1, num_pages, rest)
      elsif num_pages >= 11 && (current_page < 3 || current_page > num_pages  - 2)
        middle_page = num_pages / 2
        make_items(1, 3)
        @items << GAP
        make_items(middle_page - 1, middle_page + 1)
        @items << GAP
        make_items(num_pages - 2, num_pages, rest)
      else
        if current_page <= 5
          final_page = current_page + 1;
          final_page = 3 if final_page < 3        
          make_items(1, final_page)          
          @items << GAP
          make_items(num_pages - 2, num_pages, rest)
        elsif current_page > 4 && current_page < num_pages - 4
          make_items(1, 3)
          @items << GAP
          make_items(current_page - 1, current_page + 1)
          @items << GAP
          make_items(num_pages - 2, num_pages, rest)
        else
          initial_page = current_page - 1
          initial_page = num_pages - 2 if initial_page > num_pages - 2
          make_items(1, 3)
          @items << GAP
          make_items(initial_page, num_pages, rest)
        end
      end
    end

    def make_items(initial_page, final_page, rest = 0)
      initial_page -= 1
      for i in initial_page...final_page do      
        first_item = (@collection.per_page * i) + 1
        if i == (final_page - 1) && rest > 0  # if last page is parcial.
          last_item = (first_item + rest) - 1
        else
          last_item = @collection.per_page * (i + 1)
        end
        text = "#{sprintf('%.2d', first_item)}&nbsp;-&nbsp;#{sprintf('%.2d', last_item)}" 
        page = (i != @collection.current_page - 1) ? (i + 1) : nil # nil if current page
        @items << PaginationItem.new(text, page)
        @items << SEPARATOR unless i == final_page - 1 # if not last item.
      end
    end
  end
end