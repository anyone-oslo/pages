class Page < ActiveRecord::Base
	
	serialize :redirect_to
	
	# Relations
	belongs_to   :author, :class_name => "User", :foreign_key => :user_id
	has_and_belongs_to_many :categories, :join_table => :pages_categories

	belongs_to_image        :image
	has_and_belongs_to_many :images

	has_many :comments, :class_name => 'PageComment', :dependent => :destroy
	has_many :files, :class_name => 'PageFile', :dependent => :destroy, :order => :position

	acts_as_list :scope => :parent_page
	acts_as_tree :order => :position, :foreign_key => :parent_page_id

	acts_as_textable :name, :body, :excerpt, :headline, :boxout, :allow_any => true
	acts_as_taggable
	
	# Page status labels
	STATUS_LABELS = [ "Draft", "Reviewed", "Published", "Hidden", "Deleted" ]
	
	@@available_templates_cached = nil
	
	validates_format_of :unique_name, :with => /^[\w\d_\-]+$/, :allow_nil => true, :allow_blank => true
	validates_uniqueness_of :unique_name, :allow_nil => true, :allow_blank => true
	
	validate do |page|
		#page.errors.add( :name, 'must have a title' ) if page.name.empty? # and !page.deleted?
		page.template ||= page.default_template
	end
	
	attr_accessor :image_url, :image_description

	before_save do |page| 
		page.published_at = Time.now unless page.published_at?
		if page.image_url && !page.image_url.blank?
			temp_path = File.join(File.dirname(__FILE__), '../../../../../tmp')
			target_filename = page.image_url.split("/").last
			target_file = File.join(temp_path, target_filename)
			`curl -o #{target_file} #{page.image_url}`
			page.image = File.open(target_file)
			`rm #{target_file}`
		end
		if page.image_description && !page.image_description.blank?
			begin
				page.image.update_attribute(:description, page.image_description)
			rescue
	            # Alert?
            end
		end
	end
	
	# fuck a ferret
	#acts_as_ferret :fields => { :names_for_search => { :boost => 2 }, :content_for_search => {} }
	
	define_index do
		# Fields
		indexes textbits.body,                   :as => :textbit_bodies
		indexes categories.name,                 :as => :category_names
		indexes tags.name,                       :as => :tag_names
		indexes [author.realname, author.email], :as => :author_name
		indexes [comments.name, comments.body],  :as => :comments

		# Attributes
		has published_at, created_at, updated_at
		has user_id, parent_page_id
		has status, template
		has autopublish, feed_enabled

		has categories(:id), :as => :category_ids
		has tags(:id), :as => :tag_ids

		set_property :delta => true
	end


	# ---- CLASS METHODS ------------------------------------------------------

	class << self
		
		# Finds page with unique name
		def find_unique(name)
			page = Page.find_by_unique_name(name.to_s)
		end

		# Finds pages due for auto publishing and publishes them.
		def autopublish!(options={})
			options[:fuzziness] ||= 1.minute
			publish_timestamp = Time.now + options[:fuzziness]
			pages = self.find(:all, :conditions => ['autopublish = 1 AND autopublish_at < ?', publish_timestamp])
			pages.each do |p|
				p.update_attribute(:autopublish, false)
			end
			pages
		end
		
		# Finds pages with comments, ordered by date of last comment.
		#
		# === Parameters
		# * <tt>:limit</tt> - An integer determining the limit on the number of results that should be returned. 
		#
		# Example:
		#   Page.last_commented(:limit => 10)
		def last_commented(options={})
			find_query = "SELECT p.* FROM pages p, page_comments c 
			              WHERE c.page_id = p.id AND p.status = 2 
			              GROUP BY c.page_id ORDER BY c.created_at DESC"
			find_query << " LIMIT #{options[:limit]}" if options[:limit]
			Page.find_by_sql(find_query)
		end
	
		# Finds pages with comments, ordered by number of comments.
		#
		# === Parameters
		# * <tt>:limit</tt> - An integer determining the limit on the number of results that should be returned. 
		#
		# Example:
		#   Page.most_commented(:limit => 10)
		def most_commented(options={})
			find_query = "SELECT p.*, COUNT(c.id) as comments_count FROM pages p, page_comments c 
			              WHERE c.page_id = p.id AND p.status = 2 
			              GROUP BY c.page_id ORDER BY comments_count DESC"
			find_query << " LIMIT #{options[:limit]}" if options[:limit]
			Page.find_by_sql(find_query)
		end

		# Finds pages based on the given criteria. Only published pages are loaded by default, this can be overridden by passing the
		# <tt>:drafts</tt>, <tt>:hidden</tt>, <tt>:deleted</tt> and/or <tt>:all</tt> parameters.
		#
		# The pages will have <tt>working_language</tt> set if <tt>:language</tt> is given, this is probably what you'll want to do.
		# Only pages with translations for the given language will be returned unless <tt>:all_languages => true</tt> is specified.
		#
		# Usually, you'll want to load pages from the context of their parent, this is what <tt>Page.root_pages</tt> and <tt>Page#pages</tt> do.
		#
		# === Parameters
		# * <tt>:drafts</tt>           - Include drafts.
		# * <tt>:hidden</tt>           - Include hidden pages.
		# * <tt>:deleted</tt>          - Include deleted pages.
		# * <tt>:autopublish</tt>      - Include autopublish pages
		# * <tt>:all</tt>              - Include all of the above.
		# * <tt>:language</tt>         - Load only pages translated into this language.
		# * <tt>:all_languages</tt>    - Load all pages regardless of language.
		# * <tt>:order</tt>            - Sorting criteria, defaults to 'position'.
		# * <tt>:parent(s)</tt>        - Parent page. Can be an id, a Page or a collection of both. If parent is <tt>:root</tt>, pages at the root level will be loaded.
		# * <tt>:paginate</tt>         - Paginates results. Takes a hash with the format: {:page => 1, :per_page => 20}
		# * <tt>:category</tt>         - Loads only pages within the given category.
		# * <tt>:include</tt>          - Which relationships to include (Default: :textbits, :categories, :image, :author)
		# * <tt>:limit</tt>            - Limit results to n records.
		# * <tt>:published_after</tt>  - Loads only pages published after this date.
		# * <tt>:published_before</tt> - Loads only pages published before this date.
		# * <tt>:published_within</tt> - Loads pages published within this range.
		#
		# Examples:
		#   Page.get_pages(:parent => :root)
		#   Page.get_pages(:parent => :root, :hidden => true, :drafts => true)
		#   Page.get_pages(:parent => Page.find_by_template('news'), :published_after => 14.days.ago)
		#   Page.get_pages(:parents => Page.news_pages, :category => Category.find_by_name('music'))
		#
		# == Pagination
		#
		# The results can be paginated by setting the <tt>:paginate</tt> parameter in the form of 
		# <tt>{:page => page_number, :per_page => items_per_page }</tt>. The result set has a few methods injected
		# to make views easier to write and more readable.
		#
		# Example:
		#   news_posts = Page.get_pages(:parent => Page.find_by_template('news'), :paginate => {:page => 3, :per_page => 10})
		#   news_posts.paginated? # => true
		#   news_posts.pages # => 11
		#   news_posts.current_page # => 3
		#   news_posts.previous_page # => 2
		#   news_posts.last_page => 11
		def get_pages(options={})
			options, find_options = get_pages_options(options)

			# Pagination
			pagination_options = {}
			if options[:paginate]
				pages_count = Page.count_pages(options, find_options)
				options[:paginate][:page] ||= 1
				options[:paginate][:page] = options[:paginate][:page].to_i
				options[:paginate][:page] = 1 if options[:paginate][:page] < 1
				pagination_count = (pages_count.to_f / options[:paginate][:per_page]).ceil

				pagination_options[:offset] = options[:paginate][:per_page].to_i * ( options[:paginate][:page].to_i - 1 )
				pagination_options[:limit]  = options[:paginate][:per_page]
			end
			
			pagination_options[:limit] = options[:limit] if options[:limit]

			# Find the pages
			find_options[:include] = options[:include] if options[:include]
			pages = Page.find(:all, find_options.merge(pagination_options))

			# Set working language
			pages = pages.map{|p| p.working_language = options[:language]; p} if options[:language]

			# Add the pagination methods
			if options[:paginate] && pagination_count > 0
				PagesCore::Paginates.paginate(pages, :current_page => options[:paginate][:page], :pages => pagination_count, :per_page => options[:paginate][:per_page])
			else
				PagesCore::Paginates.paginate(pages)
			end
		
			pages
		end
		
		def search_paginated(query, options={})
			options[:page] = (options[:page] || 1).to_i

			search_options = {
				:per_page   => 20,
				:include    => [:textbits, :categories, :image, :author]
			}.merge(options)

			# TODO: Allow more fine-grained control over status filtering
			search_options[:conditions] = {:status => '2', :autopublish => '0'}
			
			pages = Page.search(query, search_options)
			PagesCore::Paginates.paginate(pages, :current_page => options[:page], :pages => pages.total_pages, :per_page => search_options[:per_page])
			pages
		end
				
		# Count pages. See Page.get_pages for options.
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
		def count_pages_by_year_and_month(options={})
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
				year, month, page_count = row.mapped.to_i
				(pages_count[year] ||= ActiveSupport::OrderedHash.new)[month] = page_count
			end
			pages_count
		end

		# Finds pages at the root level. See <tt>Page.get_pages</tt> for options, this is equal to <tt>Page.get_pages(:parent => :root, ..)</tt>.
		def root_pages(options={})
			options[:parent] ||= :root
			Page.get_pages(options)
		end
	
		# Finds all news pages (pages with the news_page bit on).
		#
		# === Parameters
		# * <tt>:language</tt> - String to set as working language for the resulting pages.
		def news_pages(options={})
			ps = Page.find(:all, :conditions => ['news_page = 1'], :order => 'published_at ASC')
			if options[:language]
				ps = ps.map{|p| p.working_language = options[:language]; p}
			end
			ps
		end
		
		# Are there any news pages?
		def news_pages?
			(Page.count(:all, :conditions => ['news_page = 1']) > 0) ? true : false
		end
	
		# Finds news items (which are pages where the parent is flagged as news_page). See <tt>Page.get_pages</tt> for more info on the options.
		def get_news(options={})
			options[:parent] ||= Page.news_pages
			options[:order] ||= "published_at DESC"
			Page.get_pages(options)
		end
	

		# Find a page by slug and language
		def find_by_slug_and_language( slug, language )
			language = language.to_s
			slug     = slug.to_s

			# Search legacy slug textbits
			if textbit = Textbit.find( :first, :conditions => [ 'name = "slug" AND textable_type = ? AND body = ? AND language = ?', self.to_s, slug, language ] )
				page = textbit.textable

			# Search page names
			else
				textbits = Textbit.find( :all, :conditions => [ "name = 'name' AND textable_type = '#{self.to_s}' AND language = ?", language ] )
				textbits = textbits.select{ |tb| Page.string_to_slug( tb.body ) == slug }
				if textbits.length > 0
					page = textbits.first.textable
				end
			end

			( page ) ? page.translate( language ) : nil
		end
	
		# Convert a string to an URL friendly slug
		def string_to_slug( string )
			#slug = (Iconv.new('US-ASCII//TRANSLIT', 'utf-8').iconv string.gsub( /[Øø]/, "oe" ).gsub( /[Åå]/, "aa" ) ).downcase
			slug = string.dup.convert_to_ascii.downcase.gsub(/[^\w\s]/,'')
			slug = slug.split( /[^\w\d\-]+/ ).compact.join( "_" )
		end

		# Find all published and feed enabled pages
		def enabled_feeds(language, options={})
			conditions = (options[:include_hidden]) ? 'feed_enabled = 1 AND status IN (2,3)' : 'feed_enabled = 1 AND status = 2'
			Page.find(:all, :conditions => conditions).collect{|p| p.working_language = language.to_s; p}
		end
		
		protected
		
			# Translates options for get_pages to options for find.
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

				options[:all]           ||= false
				options[:deleted]       ||= options[:all]
				options[:hidden]        ||= options[:all]
				options[:drafts]        ||= options[:all]
				options[:autopublish]   ||= options[:all]
				options[:all_languages] ||= false
				options[:order]         ||= "position"
				options[:parent]        = options[:parents] if options[:parents]
				options[:include]       ||= [:textbits, :categories, :image, :author]

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

				# Language check
				if options[:language] && !options[:all_languages]
					find_options[:joins] ||= ""
					options[:language] = options[:language].to_s
					raise "Not a valid language code" unless options[:language] =~ /^[\w]{2,3}$/
					find_options[:joins] += "JOIN `textbits` ON `textbits`.textable_type = \"Page\" AND `textbits`.textable_id = `pages`.id AND `textbits`.language = '#{options[:language]}' "
					find_options[:group] = "`pages`.id"
				end

				# Category check
				if options[:category]
					find_options[:joins] ||= ""
					# Multiple categories
					if options[:category].kind_of?(Enumerable)
						find_options[:joins] += "JOIN `pages_categories` ON `pages_categories`.page_id = `pages`.id AND `pages_categories`.category_id IN ("+(options[:category].map{|c| c.kind_of?(Category) ? c.id : c}.join(", "))+")"
					else
						find_options[:joins] += "JOIN `pages_categories` ON `pages_categories`.page_id = `pages`.id AND `pages_categories`.category_id = "+(options[:category].kind_of?(Category) ? options[:category].id : options[:category]).to_s
					end

				end

				# Map conditions to string
				conditions = find_options[:conditions].first.join(" AND ")
				find_options[:conditions][0] = conditions
				[options, find_options]
			end
			

	end
	


	# ---- INSTANCE METHODS ---------------------------------------------------
	
	self.send :alias_method, :acts_as_tree_parent, :parent 

	alias :textable_has_field? :has_field?
	def has_field?(field_name, options={})
		self.textable_has_field?(field_name, options) || self.template_config.all_blocks.include?(field_name.to_sym)
	end

	# Get this page's parent page.
	def parent
		parent_page = acts_as_tree_parent
		if parent_page && parent_page.kind_of?(Page)
			parent_page.translate(self.working_language)
		else
			parent_page
		end
	end
	alias_method :parent_page, :parent
	
	def tag_list=( tag_list )
		tag_with( tag_list )
	end

	self.send :alias_method, :acts_as_tree_ancestors, :ancestors 
	
	# Finds this page's ancestors
	def ancestors
		ancestors = self.acts_as_tree_ancestors
		if self.working_language
			ancestors = ancestors.map{|a| a.translate(self.working_language) }
		end
		ancestors
	end
	

	def is_ancestor?( page )
		page.ancestors.include?( self )
	end
	
	def is_or_is_ancestor?( page )
		( page == self || self.is_ancestor?( page ) ) ? true : false
	end
	
	def excerpt_or_body
		if self.excerpt?
			self.excerpt
		else
			self.body
		end
	end
	
	def headline_or_name
	    if self.headline?
	        self.headline
        else
            self.name
        end
    end
	
	def is_extended?
		( self.excerpt? && self.body? ) ? true : false
	end
	
	# Does this page have any files?
	def files?
		( !self.files.empty? ) ? true : false
	end
	
	# Get an array of available templates
	def self.available_templates
		unless @@available_templates_cached
			logger.info "caching templates"
			locations = 
			[
				File.join(File.dirname(__FILE__), '../views/pages/templates'),
				File.join(File.dirname(__FILE__), '../../../../../app/views/pages/templates')
			]
			templates = locations.collect do |location|
				Dir.entries( location ).select { |f| File.file?( File.join( location, f ) ) and !f.match( /^_/ ) } if File.exists? location
			end
			templates = templates.flatten.uniq.compact.sort.collect { |f| f.gsub(/\.[\w\d\.]+$/,'') }

			# make index the first template
			if templates.include? "index"
				templates = [ "index", templates.reject { |f| f == "index" } ].flatten
			end
			@@available_templates_cached = templates
		end
		return @@available_templates_cached
	end
	
	def default_template
		if self.parent
			t = self.parent.default_subtemplate
		else
			default_value   = PagesCore::Templates.configuration.get(:default, :template, :value)
			default_options = PagesCore::Templates.configuration.get(:default, :template, :options)
			if  default_options && default_options[:root]
				t = default_options[:root]
			elsif default_value && default_value != :autodetect
				t = default_value
			end
		end
		t ||= :index
	end
	
	def default_subtemplate
		tpl = nil
		default_template = PagesCore::Templates.configuration.get(:default, :template, :value)
		if self.template_config.value(:sub_template)
			tpl = self.template_config.value(:sub_template)
		elsif default_template && default_template != :autodetect
			tpl = default_template
		else
			# Autodetect sub template
			reject_words = ['index', 'list', 'archive', 'liste', 'arkiv']
			base_template = self.template.split(/_/).reject{|w| reject_words.include?(w) }.join(' ')
			tpl = Page.available_templates.select{ |t| t.match(Regexp.new('^'+Regexp.quote(base_template)+'_?(post|page|subpage|item)')) }.first rescue nil
			# Try to singularize the base template if the subtemplate could not be found.
			unless tpl and base_template == ActiveSupport::Inflector::singularize(base_template)
				tpl = Page.available_templates.select{ |t| t.match(Regexp.new('^'+Regexp.quote(ActiveSupport::Inflector::singularize(base_template)))) }.first rescue nil
			end
		end
		# Inherit template by default
		tpl ||= self.template
	end

	def template_config
		PagesCore::Templates::TemplateConfiguration.new(self.template)
	end

	def template
		(self[:template] && !self[:template].blank?) ? self[:template] : self.default_template.to_s
	end
	
	# Get subpages
	def pages( options={} )
		options[:parent]   ||= self.id
		options[:order]    ||= self.content_order
		options[:language] ||= self.working_language if self.working_language
		Page.get_pages( options )
	end
	
	# Count subpages
	def count_pages(options={})
		options[:parent]   ||= self.id
		options[:order]    ||= self.content_order
		options[:language] ||= self.working_language if self.working_language
		Page.count_pages(options)
	end
	alias_method :pages_count, :count_pages
	
	# Count subpages by year and month
	def count_pages_by_year_and_month(options={})
		options = options.dup
		options[:parent] ||= self
		Page.count_pages_by_year_and_month(options)
	end
	alias_method :pages_count_by_year_and_month, :count_pages_by_year_and_month

	# Get this page's root page.
	def root_page
		root_page = self
		while( root_page.parent )
			root_page = root_page.parent
		end
		root_page
	end
	
	def is_child_of( page )
		compare = self
		while( compare.parent )
			compare = compare.parent
			return true if compare == page
		end
		return false
	end
	
	# Get sibling by offset (most likely +1 or -1)
	def sibling_by_offset( offset, options={} )
		return nil unless self.parent
		siblings = self.parent.pages( options )
		raise "self not found in collection" unless siblings.include? self
		index    = siblings.index( self ) + offset
		( index >= 0 && index < siblings.length ) ? siblings[index] : nil
	end

	# Get the next sibling
	def next_sibling( options={} )
		sibling_by_offset( 1, options )
	end

	# Get the previous
	def previous_sibling( options={} )
		sibling_by_offset( -1, options )
	end

	# Return the status of the page as a string
	def status_label
		STATUS_LABELS[self.status]
	end
	
	def self.status_labels_for_options
		labels = Array.new
		Page::STATUS_LABELS.each_index {|i| labels << [Page::STATUS_LABELS[i],i] }
		labels
	end

	
	# Set the page status
	def set_status( new_status )
		new_status = new_status.to_i if new_status.kind_of?( String ) && new_status.match( /^[\d]+$/ )
		if( new_status.kind_of?( String ) || new_status.kind_of?( Symbol ) )
			new_status = new_status.to_s
			index = STATUS_LABELS.collect {|l| l.downcase}.index( new_status.downcase )
			write_attribute( :status, index ) unless index.nil?
		elsif new_status.kind_of? Numeric
			write_attribute( :status, new_status.to_i ) 
		end
	end

	# Alias get_textbit as get_field
	def get_field( name, options={} )
		get_textbit( name, options )
	end
	
	
	def template=( template_file )
		write_attribute( 'template', template_file )
	end
	
	def extended?
		( self.get_field( 'excerpt' ).to_s.strip != "" ) ? true : false
	end
	
	def blank?
		( self.get_field( 'body' ).to_s.strip == "" ) ? true : false
	end
	
	# Get word count for page
	def word_count
		words = self.body.to_s
		words.gsub! /<\/?[^>]*>/, ''     # strip html tags
		words.gsub! /[^\w^\s]/, ''       # remove all non-word/space chars
		words.split( /[\s]+/ ).length    # split by spaces and return length
	end
	
	
	# Get publication date, which defaults to the creation date
	def published_at
		self[:published_at] ||= self.created_at
	end


	# Get the first page which redirects to the given options.
	# Example:
	#   @page = Page.for_request( params, [ :controller, :action ] )
	def self.for_request( options={}, limit=nil )
		raise "Limit has to be nil or an array" if limit and !limit.kind_of?( Array )
		if limit
			limit = limit.collect { |l| l.to_sym }
			options = options.dup.delete_if{ |key,value| !limit.include? key.to_sym }
		end
		options = options.symbolize_keys

		# Load pages with redirect_to and get the first one that matches the criteria
		page = Page.find( :all, :conditions => ['redirect_to IS NOT NULL'] ).select do |p|
			redirect = p.redirect_to
			redirect.kind_of? Hash and options.reject { |k,v| redirect[k] == v }.empty?
		end.first rescue nil
		
		# Default to a blank page, so the template won't bork
		page ||= Page.new
	end


	# Returns boolean true if page has a valid redirect
	def redirects?
		return false if self.redirect_to == "0"
		return true if self.redirect_to.kind_of? String and !self.redirect_to.strip.empty?
		return true if self.redirect_to.kind_of? Hash   and !self.redirect_to.empty?
		return false
	end
	

	# Take the given options and merge self.redirect_to with them. If self.redirect_to is a string, nothing will be merged. 
	def redirect_to_options( options={} )
		options.symbolize_keys!
		redirect = self.redirect_to
		if redirect.kind_of? Hash
			redirect.symbolize_keys!
			options.delete :language unless redirect.has_key? :language
			redirect.delete :language if options.has_key? :language
			redirect = options.merge redirect
		end
		redirect
	end
	

	# Returns true if this page is reorderable
	def reorderable?
		( !self.parent || !self.parent.content_order? || ( self.parent.content_order =~ /position/ )  ) ? true : false
	end


	# Imports subpages from XML
	def import_xml(xmldata)
		created_pages = []
		require 'rexml/document'
		doc = REXML::Document.new(xmldata)
		doc.elements.each('pages/page') do |page_xml|
			attributes = Hash.from_xml(page_xml.to_s)['page']
			attributes.merge!({'parent_page_id' => self.id})
			if attributes.has_key?('author_email')
				author = User.exists?(:email => attributes['author_email']) ? User.find_by_email(attributes['author_email']): self.author
				attributes.delete('author_email')
			else
				author = self.author
			end
			page = Page.new.translate(self.working_language)
			page.author = author
			if page.update_attributes(attributes)
				created_pages << page
			end
		end
		created_pages
	end

	# Enable virtual setters and getters for existing (and enforced) textbits
	def method_missing( method_name, *args )
		name = method_name.to_s
		# Booleans
		if( n = name.match( /(.*)\?/ ) )

			downcase_labels = STATUS_LABELS.collect{|l| l.downcase }
			if downcase_labels.include?( n[1].downcase ) 
				return ( self.status == downcase_labels.index( n[1].downcase ) ) ? true : false
			else
				super
			end
		else
			super
		end
	end
	
	# Set categories from string
	def category_names=(names)
		if names
			names = names.split(/[\s]*,[\s]*/).reject{|n| n.blank?}
			if names.length > 0
				categories = names.map do |name|
					cat = Category.exists?(:name => name) ? Category.find_by_name(name) : Category.create(:name => name)
				end
			end
			self.categories = categories
		end
	end
	
	# Is this page published?
	def published?
		(self.status == 2 && !self.autopublish?) ? true : false
	end

	def slug
		self.class.string_to_slug( self.name.to_s )
	end
	
	def to_param
		"#{id}-#{self.slug}"
	end
	
	def content_order
		self[:content_order] || 'position'
	end
	
	def empty?
		( ( self.body.to_s + self.excerpt.to_s ).strip.empty? ) ? true : false
	end
	
end
