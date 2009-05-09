
module WillPaginate

  module Finder

    module ClassMethods

      def current_page(page)
        return 1 if page.blank?
        page == 'last' ? :last : page.to_i
      end

      def order_by(order_by, desc)
        "#{order_by}#{' DESC' if desc == '1'}"
      end

      alias :old_paginate :paginate
      
      def paginate(*args, &block)                
        options = args.pop
        
        if options[:page] == :last
          last_page = true
          options[:page] = 1 # just to avoid parse error
        end
        
        page, per_page, total_entries = wp_parse_options(options)
        finder = (options[:finder] || 'find').to_s

        if finder == 'find'
          # an array of IDs may have been given:
          total_entries ||= (Array === args.first and args.first.size)
          # :all is implicit
          args.unshift(:all) if args.empty?
        end

        count_options = options.except :page, :per_page, :total_entries, :finder        
        find_options = count_options.except(:count)
        
        args << find_options
          
        # magic counting for user convenience:
        total_entries = wp_count(count_options, args, finder) unless total_entries

        total_pages = (total_entries / per_page.to_f).ceil

        if total_pages > 0
          page = total_pages if last_page || page > total_pages
        else
          page = 1
        end
        
        WillPaginate::Collection.create(page, per_page, total_entries) do |pager|
          find_options.update(:offset => pager.offset, :limit => pager.per_page)
          pager.replace send(finder, *args, &block)
        end
      end
    end
  end
end










