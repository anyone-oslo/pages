require 'language'
require 'unicode'
require 'iconv'
require 'yaml'
require 'manual_support'

class Page < ActiveRecord::Base
	
	serialize :redirect_to
	
	# Relations
	#belongs_to   :parent_page, :class_name => "Page"
	belongs_to   :author, :class_name => "User", :foreign_key => :user_id
	belongs_to_image   :image
	
	has_and_belongs_to_many :images

	acts_as_list :scope => :parent_page
	acts_as_tree :order => :position, :foreign_key => :parent_page_id

	acts_as_textable [ "name", "body", "excerpt", "headline", "boxout" ], :allow_any => true

	has_and_belongs_to_many :categories, :join_table => :pages_categories

	has_many :comments, :class_name => 'PageComment', :dependent => :destroy
	has_many :files, :class_name => 'PageFile', :dependent => :destroy, :order => :position
	
	acts_as_taggable
	
	STATUS_LABELS = [ "Draft", "Reviewed", "Published", "Hidden", "Deleted" ]
	
	@@available_templates_cached = nil
	@@cached_pages = {}
	
	validate do |page|
		page.errors.add( :name, 'must have a title' ) if page.name.empty? # and !page.deleted?
		page.template ||= page.default_template
		#if page.slug.empty?
		#	page.slug = Unicode::normalize_KD(page.name.to_s+"-").downcase.gsub(/[^a-z0-9\s_-]+/,'').gsub(/[\s_-]+/,'-')[0..-2]
		#end
	end
	
	before_save    { |page| Page.expire_pages_cache! }
	before_create  { |page| Page.expire_pages_cache! }
	before_destroy { |page| Page.expire_pages_cache! }
	before_save    { |page| page.published_at = Time.now unless page.published_at? }
	
	acts_as_ferret :fields => { :names_for_search => { :boost => 2 }, :content_for_search => {} }

	# ---- CLASS METHODS ------------------------------------------------------

	class << self
		
		def hash_to_key( hash )
			array = hash.stringify_keys.to_a.sort{ |a,b| a.first <=> b.first }
			key   = array.to_s
		end

		def get_cached_pages( options )
			return false
			key = self.hash_to_key( options )
			if @@cached_pages.kind_of?( Hash ) && @@cached_pages.has_key?( key )
				@@cached_pages[key]
			else 
				nil
			end
		end
		
		def set_cached_pages( options, pages )
			key = self.hash_to_key( options )
			@@cached_pages[key] = pages
		end
		
		def expire_pages_cache!
			@@cached_pages = {}
		end
		
		def last_commented(options={})
			options[:limit] ||= 20
			Page.find_by_sql("SELECT p.* FROM pages p, page_comments c WHERE c.page_id = p.id AND p.status = 2 GROUP BY c.page_id ORDER BY c.created_at DESC LIMIT #{options[:limit]}")
		end
		
		def most_commented(options={})
			options[:limit] ||= 20
			Page.find_by_sql("SELECT p.*, COUNT(c.id) as comments_count FROM pages p, page_comments c WHERE c.page_id = p.id AND p.status = 2 GROUP BY c.page_id ORDER BY comments_count DESC LIMIT #{options[:limit]}")
		end


		# Get a collection of pages based on certain criteria
		def get_pages( options={} )
			options[:show_all]     ||= false
			options[:show_deleted] ||= options[:show_all]
			options[:show_hidden]  ||= options[:show_all]
			options[:show_drafts]  ||= options[:show_all]
			options[:show_all_languages] ||= false
			options[:order]        ||= "position"

			if options[:skip_parent]
				conditions = "true"
			elsif options[:parent] && options[:parent].kind_of?(Enumerable)
				parent_ids = options[:parent].map{|p| p.kind_of?(Page) ? p.id : p}
				conditions = "parent_page_id IN (" + parent_ids.join(", ") + ")"
			elsif options[:parent]
				parent_id = options[:parent]
				parent_id = parent.id if parent_id.kind_of?(Page)
				conditions = "parent_page_id = #{parent_id}"
			else
				conditions = "parent_page_id IS NULL"
			end

			unless options[:show_all] || options[:show_deleted] || options[:show_hidden] || options[:show_drafts]
				conditions << " AND status = 2"
			else
				conditions << " AND status < 4"   unless options[:show_deleted]
				conditions << " AND status != 3"  unless options[:show_hidden]
				conditions << " AND status >= 2"  unless options[:show_drafts]
			end

			# Prepend 'pages.' to order clauses to disambigue the query.
			options[:order] = options[:order].split( /,[\s]*/ ).map{ |c| (c =~ /^pages\./ ) ? c : "pages."+c }.join(", ")
			
			# Try the cache first
			unless pages = self.get_cached_pages( options )

				find_opts = {
					:conditions => conditions, 
					:order => options[:order], 
					:include => [:textbits]
				}

				pages = Page.find(:all, find_opts)
				
				# Check for languages and remap the collection
				pages = pages.collect do |page|
					if options[:language]
						if options[:show_all_languages] || page.languages.include?( options[:language] )
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

					#unless options[:paginate][:page] >= 1 && options[:paginate][:page] <= pagination_count
					#	options[:paginate][:page] = 1
					#end
				end

				# Add pagination methods to the collection
				# TODO: Make a module for this
				class << pages
					attr_reader :paginated, :current_page, :pages, :per_page
					def set_pagination( paginated=false, current_page=1, pages=1, per_page=nil )
						@paginated, @current_page, @pages, @per_page = paginated, current_page.to_i, pages.to_i, per_page.to_i
					end
					def paginated?;    (@paginated) ? true : false; end
					def next_page;     (@current_page < @pages) ? ( @current_page + 1 ) : nil; end
					def previous_page; (@current_page > 1) ? ( @current_page - 1 ) : nil; end
					def last_page;     @pages; end
					def first_page;    1; end
				end

				if options[:paginate] && pagination_count > 0
					pages.set_pagination( true, options[:paginate][:page], pagination_count, options[:paginate][:per_page] )
				else
					pages.set_pagination
				end
				
				self.set_cached_pages( options, pages )
			end
			pages
		end

		# Get a collection of pages at root level
		def root_pages( options={} )
			Page.get_pages( options )
		end
		
		def news_pages(options={})
			ps = Page.find(:all, :conditions => ['news_page = 1'], :order => 'id ASC')
			if options[:language]
				ps = ps.map{|p| p.working_language = options[:language]; p}
			end
			ps
		end
		
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
	
	alias_method :acts_as_tree_parent, :parent
	def parent
		parent_page = acts_as_tree_parent
		parent_page.working_language = self.working_language if parent_page && parent_page.kind_of?(Page)
		parent_page
	end
	
	def tag_list=( tag_list )
		tag_with( tag_list )
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
				File.join(File.dirname(__FILE__), '../views/pages'),
				File.join(File.dirname(__FILE__), '../../../../../app/views/pages')
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
		unless tpl and parent_template == Inflector::singularize( parent_template )
			tpl = Page.available_templates.select{ |t| t.match( Regexp.new( '^'+Regexp.quote( Inflector::singularize( parent_template ) ) ) ) }.first rescue nil
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
