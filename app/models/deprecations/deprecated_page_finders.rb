module Deprecations
  module DeprecatedPageFinders
    extend ActiveSupport::Concern

    module ClassMethods
      # Finds pages based on the given criteria. Only published pages are loaded by default, this can be overridden by passing the
      # <tt>:drafts</tt>, <tt>:hidden</tt>, <tt>:deleted</tt> and/or <tt>:all</tt> parameters.
      #
      # The pages will have <tt>locale</tt> set if <tt>:locale</tt> is given, this is probably what you'll want to do.
      # Only pages with translations for the given locale will be returned unless <tt>:all_locales => true</tt> is specified.
      #
      # Usually, you'll want to load pages from the context of their parent, this is what <tt>Page.root_pages</tt> and <tt>Page#pages</tt> do.
      #
      # === Parameters
      # * <tt>:drafts</tt>           - Include drafts.
      # * <tt>:hidden</tt>           - Include hidden pages.
      # * <tt>:deleted</tt>          - Include deleted pages.
      # * <tt>:autopublish</tt>      - Include autopublish pages
      # * <tt>:all</tt>              - Include all of the above.
      # * <tt>:locale</tt>           - Load only pages translated into this locale.
      # * <tt>:all_locales</tt>      - Load all pages regardless of locale.
      # * <tt>:order</tt>            - Sorting criteria, defaults to 'position'.
      # * <tt>:parent(s)</tt>        - Parent page. Can be an id, a Page or a collection of both. If parent is <tt>:root</tt>, pages at the root level will be loaded.
      # * <tt>:paginate</tt>         - Paginates results. Takes a hash with the format: {:page => 1, :per_page => 20}
      # * <tt>:category</tt>         - Loads only pages within the given category.
      # * <tt>:include</tt>          - Which relationships to include (Default: :localizations, :categories, :image, :author)
      # * <tt>:comments</tt>         - Limit results to pages with comments.
      # * <tt>:limit</tt>            - Limit results to n records.
      # * <tt>:published_after</tt>  - Loads only pages published after this date.
      # * <tt>:published_before</tt> - Loads only pages published before this date.
      # * <tt>:published_within</tt> - Loads pages published within this range.
      #
      # Examples:
      #   Page.get_pages(:parent => :root)
      #   Page.get_pages(:parent => :root, :hidden => true, :drafts => true)
      #   Page.get_pages(:parent => Page.where(template: 'news'), :published_after => 14.days.ago)
      #   Page.get_pages(:parents => Page.news_pages, :category => Category.where(name: 'music'))
      #
      # == Pagination
      #
      # The results can be paginated by setting the <tt>:paginate</tt> parameter in the form of
      # <tt>{:page => page_number, :per_page => items_per_page }</tt>. The result set has a few methods injected
      # to make views easier to write and more readable.
      #
      # Example:
      #   news_posts = Page.get_pages(:parent => Page.where(template: 'news'), :paginate => {:page => 3, :per_page => 10})
      #   news_posts.paginated? # => true
      #   news_posts.pages # => 11
      #   news_posts.current_page # => 3
      #   news_posts.previous_page # => 2
      #   news_posts.last_page => 11

      # TODO: Safe to remove, not used in plugin
      def get_pages(options={})
        ActiveSupport::Deprecation.warn "Page.get_pages is deprecated, use ARel scopes instead."

        options, find_options = get_pages_options(options)

        # Pagination
        pagination_options = {}
        if options[:paginate]
          # Count total pages
          options[:paginate][:offset] = (options[:paginate][:offset] || 0).to_i
          pages_count = (Page.count_pages(options, find_options) - options[:paginate][:offset])

          options[:paginate][:page] = (options[:paginate][:page] || 1).to_i
          options[:paginate][:page] = 1 if options[:paginate][:page] < 1
          pagination_count = (pages_count.to_f / options[:paginate][:per_page]).ceil

          pagination_options[:offset] = (options[:paginate][:per_page].to_i * (options[:paginate][:page].to_i - 1)) + options[:paginate][:offset]
          pagination_options[:offset] = 0 if pagination_options[:offset] < 0 # Failsafe
          pagination_options[:limit]  = options[:paginate][:per_page]
        end

        pagination_options[:limit] = options[:limit] if options[:limit]

        # Find the pages
        find_options[:include] = options[:include] if options[:include]
        pages = Page.find(:all, find_options.merge(pagination_options))

        # Set locale
        if options[:locale]
          pages = pages.map{|p| p.locale = options[:locale]; p}
        end

        # Decorate with the pagination methods
        if options[:paginate] && pagination_count > 0
          PagesCore::Paginates.paginate(pages, {
            :current_page => options[:paginate][:page],
            :pages        => pagination_count,
            :per_page     => options[:paginate][:per_page],
            :offset       => options[:paginate][:offset]
          })
        else
          PagesCore::Paginates.paginate(pages)
        end

        pages
      end

      # Finds pages at the root level. See <tt>Page.get_pages</tt> for options, this is equal to <tt>Page.get_pages(:parent => :root, ..)</tt>.
      # TODO: Safe to remove, not used in plugin
      def root_pages(options={})
        ActiveSupport::Deprecation.warn "Page.root_pages is deprecated, use Page.roots instead."
        options[:parent] ||= :root
        Page.get_pages(options)
      end

      def search_paginated(query, options={})
        ActiveSupport::Deprecation.warn "Page.search_paginated is deprecated, use a pagination gem instead."
        options[:page] = (options[:page] || 1).to_i

        if locale = options[:locale]
          options.delete(:locale)
        end

        search_options = {
          :per_page   => 20,
          :include    => [:localizations, :categories, :image, :author]
        }.merge(options)

        # TODO: Allow more fine-grained control over status filtering
        search_options[:with] = {:status => 2, :autopublish => 0}

        if options[:category_id]
          search_options[:with][:category_ids] = options[:category_id]
        end

        pages = Page.search(query, search_options)

        if locale
          pages.each_with_index do |p, i|
            pages[i].locale = locale
          end
        end

        PagesCore::Paginates.paginate(
          pages,
          :current_page => options[:page],
          :pages        => pages.total_pages,
          :per_page     => search_options[:per_page]
        )
        pages
      end

      # Count pages. See Page.get_pages for options.
      # TODO: Safe to remove, not used in plugin
      def count_pages(options={}, find_options=nil)
        unless find_options
          options, find_options = get_pages_options(options)
        end

        # Count all pages
        count_options = find_options.dup
        count_options.delete(:group)
        count_options[:select] = "DISTINCT `pages`.id"
        Page.count(:all, count_options)
      end

      # Count subpages by year and month.
      # TODO: Safe to remove, not used in plugin
      def count_pages_by_year_and_month(options={})
        ActiveSupport::Deprecation.warn "Page.count_pages_by_year_and_month is deprecated, rewrite."
        options[:all]           ||= false
        options[:deleted]       ||= options[:all]
        options[:hidden]        ||= options[:all]
        options[:drafts]        ||= options[:all]
        options[:autopublish]   ||= options[:all]

        query = {
          :select   => "SELECT YEAR(p.published_at) AS year, MONTH(p.published_at) AS month, COUNT(p.id) AS page_count",
          :from     => "FROM pages p",
          :where    => [],
          :group_by => "GROUP BY year, month"
        }

        # Join tables if a category is provided
        if options[:category]
          query[:from]   = "FROM pages p, pages_categories c "
          query[:where] << "c.category_id = #{options[:category].id} AND c.page_id = p.id"
        end

        # Parent(s)
        if options[:parent] && options[:parent] == :root
          query[:where] << "p.parent_page_id IS NULL"
        elsif options[:parent] && options[:parent].kind_of?(Enumerable)
          parent_ids = options[:parent].map{|p| p.kind_of?(Page) ? p.id : p}
          query[:where] <<  "p.parent_page_id IN (" + parent_ids.join(", ") + ")"
        elsif options[:parent]
          parent_id = options[:parent]
          parent_id = parent_id.id if parent_id.kind_of?(Page)
          query[:where] <<  "p.parent_page_id = #{parent_id}"
        end

        # Page status
        unless options[:all] || options[:deleted] || options[:hidden] || options[:drafts]
          query[:where] << "status = 2"
        else
          query[:where] << "status < 4"   unless options[:deleted]
          query[:where] << "status != 3"  unless options[:hidden]
          query[:where] << "status >= 2"  unless options[:drafts]
        end
        query[:where] << "autopublish = 0" unless options[:autopublish]

        # Construct the query
        if query[:where].length > 0
          pages_count_query = [
            query[:select],
            query[:from],
            "WHERE "+query[:where].join(" AND "),
            query[:group_by]
          ].join(" ")
        else
          pages_count_query = [
            query[:select],
            query[:from],
            query[:group_by]
          ].join(" ")
        end

        pages_count = ActiveSupport::OrderedHash.new
        ActiveRecord::Base.connection.execute(pages_count_query).each do |row|
          year, month, page_count = row.map{|r| r.to_i}
          (pages_count[year] ||= ActiveSupport::OrderedHash.new)[month] = page_count
        end
        pages_count
      end

      private

      # Translates options for get_pages to options for find.
      # TODO: Safe to remove, not used in plugin
      def get_pages_options(options={})
        options.symbolize_keys!

        # Clean up depreceated options
        options.keys.each do |key|
          if key.to_s =~ /^show_/
            new_key = key.to_s.gsub(/^show_/,'').to_sym
            logger.warn "DEPRECEATED: Option :#{key} is deprecated, use :#{new_key}"
            options[new_key] = options[key]
          end
        end

        if options.has_key?(:language)
          options[:locale] = options[:language]
          options.delete(:language)
          logger.warn "DEPRECEATED: Option :language is deprecated, use :locale"
        end
        if options.has_key?(:all_languages)
          options[:all_locales] = options[:all_languages]
          options.delete(:all_languages)
          logger.warn "DEPRECEATED: Option :all_languages is deprecated, use :all_locales"
        end

        options[:all]         ||= false
        options[:deleted]     ||= options[:all]
        options[:hidden]      ||= options[:all]
        options[:drafts]      ||= options[:all]
        options[:autopublish] ||= options[:all]
        options[:all_locales] ||= false
        options[:comments]    ||= false
        options[:order]       ||= "position"
        options[:parent]      = options[:parents] if options[:parents]
        options[:include]     ||= [:localizations, :categories, :image, :author]

        find_options = {
          :conditions => [[]]
        }

        # Ordering subpages
        find_options[:order] = options[:order]

        # Parent check
        if options[:parent] && options[:parent] == :root
          find_options[:conditions].first << "parent_page_id IS NULL"
        elsif options[:parent] && options[:parent].kind_of?(Enumerable)
          parent_ids = options[:parent].map{|p| p.kind_of?(Page) ? p.id : p}
          find_options[:conditions].first << "parent_page_id IN (" + parent_ids.join(", ") + ")"
        elsif options[:parent]
          parent_id = options[:parent]
          parent_id = parent_id.id if parent_id.kind_of?(Page)
          find_options[:conditions].first << "parent_page_id = #{parent_id}"
        end

        # Status check
        unless options[:all] || options[:deleted] || options[:hidden] || options[:drafts]
          find_options[:conditions].first << "status = 2"
        else
          find_options[:conditions].first << "status < 4"   unless options[:deleted]
          find_options[:conditions].first << "status != 3"  unless options[:hidden]
          find_options[:conditions].first << "status >= 2"  unless options[:drafts]
        end
        find_options[:conditions].first << "autopublish = 0" unless options[:autopublish]

        # Date limit check
        if options[:published_within]
          options[:published_before] = options[:published_within].last
          options[:published_after]  = options[:published_within].first
        end
        if options[:published_before] || options[:published_after]
          if options[:published_before]
            find_options[:conditions].first << "published_at <= ?"
            find_options[:conditions] << options[:published_before]
          end
          if options[:published_after]
            find_options[:conditions].first << "published_at >= ?"
            find_options[:conditions] << options[:published_after]
          end
        end

        # Check for comments
        if options[:comments]
          find_options[:conditions].first << 'comments_count > 0'
        end

        # Language check
        if options[:locale] && !options[:all_locales]
          find_options[:joins] ||= ""
          options[:locale] = options[:locale].to_s
          raise "Not a valid locale" unless options[:locale] =~ /^[\w]{2,3}$/
          find_options[:joins] += "JOIN `localizations` ON `localizations`.localizable_type = \"Page\" AND `localizations`.localizable_id = `pages`.id AND `localizations`.locale = '#{options[:locale]}' "
          find_options[:group] = "`pages`.id"
        end

        # Category check
        options[:category] = options[:categories] if options[:categories]
        if options[:category]
          find_options[:joins] ||= ""
          # Multiple categories
          if options[:category].kind_of?(Enumerable)
            find_options[:joins] += "JOIN `pages_categories` ON `pages_categories`.page_id = `pages`.id AND `pages_categories`.category_id IN ("+(options[:category].map{|c| c.kind_of?(Category) ? c.id : c}.join(", "))+")"
          else
            find_options[:joins] += "JOIN `pages_categories` ON `pages_categories`.page_id = `pages`.id AND `pages_categories`.category_id = "+(options[:category].kind_of?(Category) ? options[:category].id : options[:category]).to_s
          end
          find_options[:group] = "`pages`.id"
        end

        # Map conditions to string
        conditions = find_options[:conditions].first.join(" AND ")
        find_options[:conditions][0] = conditions
        [options, find_options]
      end

    end

    # TODO: Safe to remove, not used in plugin
    def files?
      ActiveSupport::Deprecation.warn "Page#files? is deprecated, use Page#files.any? instead."
      files.any?
    end

    # TODO: Safe to remove, not used in plugin
    def images?
      ActiveSupport::Deprecation.warn "Page#images? is deprecated, use Page#images.any? instead."
      images.any?
    end

    # Returns true if this page is a child of the given page.
    # TODO: Safe to remove, not used in plugin
    def is_child_of(page)
      ActiveSupport::Deprecation.warn "Page#is_child_of is deprecated, use Page#ancestors.include? instead."
      ancestors.include?(page)
    end

    # TODO: Safe to remove, not used in plugin
    def is_or_is_ancestor?(page)
      ActiveSupport::Deprecation.warn "Page#is_or_is_ancestor?(page) is deprecated, use page.self_and_ancestors.include? instead."
      page.self_and_ancestors.include?(self)
    end

    # TODO: Safe to remove, not used in plugin
    def parent_page
      ActiveSupport::Deprecation.warn "Page#parent_page is deprecated, use Page#parent instead."
      parent
    end

    # TODO: Safe to remove, not used in plugin
    def root_page
      ActiveSupport::Deprecation.warn "Page#root_page is deprecated, use Page#root instead."
      root
    end

    private

    def get_pages_with_hash(options={})
      return [] if self.new_record? && !options.has_key?(:parent)
      options[:parent] ||= self.id
      if self.news_page?
        options[:order] ||= "pinned DESC, #{self.content_order}"
      else
        options[:order] ||= self.content_order
      end
      options[:locale] ||= self.locale if self.locale
      Page.get_pages(options)
    end

  end
end