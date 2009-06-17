
module WillPaginate

  module Finder

    module ClassMethods

      def order_by(order_by, desc)
        "#{order_by}#{' DESC' if desc == '1'}"
      end

      alias :old_paginate :paginate
      alias :old_wp_parse_options :wp_parse_options

      def paginate(*args, &block)                
        options = args.pop

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
          page = total_pages if page == :last || page > total_pages # last page also if page is greater than total pages
        end
        
        WillPaginate::Collection.create(page, per_page, total_entries) do |pager|
          find_options.update(:offset => pager.offset, :limit => pager.per_page)
          pager.replace send(finder, *args, &block)
        end
      end

      def wp_parse_options(options) #:nodoc:
        raise ArgumentError, 'parameter hash expected' unless options.respond_to? :symbolize_keys
        options = options.symbolize_keys
        raise ArgumentError, ':page parameter required' unless options.key? :page

        if options[:count] and options[:total_entries]
          raise ArgumentError, ':count and :total_entries are mutually exclusive'
        end

        page     = parse_page(options[:page])
        per_page = options[:per_page] || self.per_page
        total    = options[:total_entries]
        [page, per_page, total]
      end

      def parse_page(page)
        return 1 if page.blank?
        return :last if page == 'last' || page == :last
        begin
          Integer(page)
        rescue
          1
        end
      end
    end
  end
end










