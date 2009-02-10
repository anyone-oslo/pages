require 'language'
require 'unicode'
require 'iconv'
require 'yaml'
#require 'manual_support'

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

	acts_as_textable [ "name", "body", "excerpt", "headline", "boxout" ], :allow_any => true
	acts_as_taggable
	
	# Page status labels
	STATUS_LABELS = [ "Draft", "Reviewed", "Published", "Hidden", "Deleted" ]
	
	@@available_templates_cached = nil
	
	validate do |page|
		#page.errors.add( :name, 'must have a title' ) if page.name.empty? # and !page.deleted?
		page.template ||= page.default_template
	end
	
	before_save    { |page| page.published_at = Time.now unless page.published_at? }
	
	# fuck a ferret
	#acts_as_ferret :fields => { :names_for_search => { :boost => 2 }, :content_for_search => {} }
	
	# define_index do
	# 	# fields
	# 	#indexes [author.realname, author.email], :as => author_name
	# 	
	# 	# attributes
	# 	has published_at, status, user_id, template, parent_page_id
	# 
	# 	#set_property :delta => true
	# end
	

	# ---- CLASS METHODS ------------------------------------------------------

	class << self
		
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

			options[:parent] = options[:parents] if options[:parents]

			if options[:parent] && options[:parent] == :root
				conditions = "parent_page_id IS NULL"
			elsif options[:parent] && options[:parent].kind_of?(Enumerable)
				parent_ids = options[:parent].map{|p| p.kind_of?(Page) ? p.id : p}
				conditions = "parent_page_id IN (" + parent_ids.join(", ") + ")"
			elsif options[:parent]
				parent_id = options[:parent]
				parent_id = parent.id if parent_id.kind_of?(Page)
				conditions = "parent_page_id = #{parent_id}"
			else
				conditions = "true"
			end

			unless options[:all] || options[:deleted] || options[:hidden] || options[:drafts]
				conditions << " AND status = 2"
			else
				conditions << " AND status < 4"   unless options[:deleted]
				conditions << " AND status != 3"  unless options[:hidden]
				conditions << " AND status >= 2"  unless options[:drafts]
			end
			conditions << " AND autopublish = 0" unless options[:autopublish]
		
			if options[:published_within]
				options[:published_before] = options[:published_within].last
				options[:published_after]  = options[:published_within].first
			end
			if options[:published_before] || options[:published_after]
				conditions = [conditions]
				if options[:published_before]
					conditions.first << " AND published_at <= ?"
					conditions << options[:published_before]
				end
				if options[:published_after]
					conditions.first << " AND published_at >= ?"
					conditions << options[:published_after]
				end
			end

			# Prepend 'pages.' to order clauses to disambigue the query.
			options[:order] = options[:order].split( /,[\s]*/ ).map{ |c| (c =~ /^pages\./ ) ? c : "pages."+c }.join(", ")
		
			find_opts = {
				:conditions => conditions, 
				:order => options[:order], 
				:include => [:textbits,:categories]
			}

			pages = Page.find(:all, find_opts)
		
			if options[:category]
				pages = pages.select{|p| p.categories.include?(options[:category])}
			end
		
			# Check for languages and remap the collection
			pages = pages.collect do |page|
				if options[:language]
					if options[:all_languages] || page.languages.include?( options[:language] )
						page.working_language = options[:language]
						page
					else
						nil
					end
				else
					page
				end
			end.compact

			# Paginate pages
			if options[:paginate]
				options[:paginate][:page] ||= 1
				options[:paginate][:page] = options[:paginate][:page].to_i
				options[:paginate][:page] = 1 if options[:paginate][:page] < 1
				pagination_count = (pages.length.to_f / options[:paginate][:per_page]).ceil

				start_index = options[:paginate][:per_page].to_i * ( options[:paginate][:page].to_i - 1 )
				end_index = start_index + options[:paginate][:per_page]
				pages = pages[start_index...end_index]
			end

			# Add pagination methods to the collection
			# TODO: Make a module for this
			class << pages
				attr_reader :paginated, :current_page, :pages, :per_page
				def set_pagination(paginated=false, current_page=1, pages=1, per_page=nil)
					@paginated, @current_page, @pages, @per_page = paginated, current_page.to_i, pages.to_i, per_page.to_i
				end
				def paginated?;    (@paginated) ? true : false; end
				def next_page;     (@current_page < @pages) ? ( @current_page + 1 ) : nil; end
				def previous_page; (@current_page > 1) ? ( @current_page - 1 ) : nil; end
				def last_page;     @pages; end
				def first_page;    1; end
			end

			if options[:paginate] && pagination_count > 0
				pages.set_pagination(true, options[:paginate][:page], pagination_count, options[:paginate][:per_page])
			else
				pages.set_pagination
			end
		
			pages
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
			ps = Page.find(:all, :conditions => ['news_page = 1'], :order => 'id ASC')
			if options[:language]
				ps = ps.map{|p| p.working_language = options[:language]; p}
			end
			ps
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
			slug = string.dup.ascii.downcase.gsub(/[^\w\s]/,'')
			slug = slug.split( /[^\w\d\-]+/ ).compact.join( "_" )
		end

		# Find all published and feed enabled pages
		def enabled_feeds( language )
			Page.find( :all, :conditions => 'feed_enabled = 1 AND status = 2' ).collect{ |p| p.working_language = language.to_s; p }
		end

	end
	


	# ---- INSTANCE METHODS ---------------------------------------------------
	
	self.send :alias_method, :acts_as_tree_parent, :parent 

	# Get this page's parent page.
	def parent
		parent_page = acts_as_tree_parent
		parent_page.working_language = self.working_language if parent_page && parent_page.kind_of?(Page)
		parent_page
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
		return nil unless self.parent and self.parent.template
		reject_words = [ 'index', 'list', 'archive', 'liste', 'arkiv' ]
		parent_template = parent.template.split(/_/).reject { |w| reject_words.include? w }.join( " " )
		
		tpl = Page.available_templates.select{ |t| t.match( Regexp.new( '^'+Regexp.quote( parent_template )+'_?(post|page|subpage|item)' ) ) }.first rescue nil
		unless tpl and parent_template == ActiveSupport::Inflector::singularize( parent_template )
			tpl = Page.available_templates.select{ |t| t.match( Regexp.new( '^'+Regexp.quote( ActiveSupport::Inflector::singularize( parent_template ) ) ) ) }.first rescue nil
		end
		tpl ||= "index"
	end

	def template
		self[:template] || self.default_template
	end
	
	# Returns boolean true if template has an image slot
	def template_has_image?
		if self.template?
			( self.template.humanize.downcase.match( /(with|med) (image|bilde)/ ) ) ? true : false
		else
			false
		end
	end

	
	# Get subpages
	def pages( options={} )
		options[:parent]   ||= self.id
		options[:order]    ||= self.content_order
		options[:language] ||= self.working_language if self.working_language
		Page.get_pages( options )
	end
	
	# Count subpages by year and month
	def pages_count_by_year_and_month(options={})
		if options[:category]
			pages_count_query = "SELECT YEAR(p.published_at) AS year, MONTH(p.published_at) AS month, COUNT(p.id) AS page_count 
			                     FROM pages p, pages_categories c
			                     WHERE c.category_id = #{options[:category].id} AND c.page_id = p.id AND p.parent_page_id = #{self.id} AND p.status = 2 
			                     GROUP BY year, month"
		else
			pages_count_query = "SELECT YEAR(p.published_at) AS year, MONTH(p.published_at) AS month, COUNT(p.id) AS page_count 
			                     FROM pages p 
			                     WHERE p.parent_page_id = #{self.id} AND p.status = 2 
			                     GROUP BY year, month"
		end
		pages_count = ActiveSupport::OrderedHash.new
		ActiveRecord::Base.connection.execute(pages_count_query).each do |row|
			year, month, page_count = row.mapped.to_i
			(pages_count[year] ||= ActiveSupport::OrderedHash.new)[month] = page_count
		end
		pages_count
	end
	

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
	
	# Is this page published?
	def published?
		(self.status == 2 && !self.autopublish?) ? true : false
	end

    def names_for_search
        self.textbits.select{ |tb| tb.name == "name" }.map{ |tb| tb.to_s }.join("\n")
    end

    def content_for_search
        self.textbits.select{ |tb| tb.name == "body" }.map{ |tb| tb.to_s }.join("\n")
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
