# encoding: utf-8

class Page < ActiveRecord::Base
  include Deprecations::DeprecatedPageFinders

  serialize :redirect_to

  belongs_to   :author, :class_name => "User", :foreign_key => :user_id
  has_and_belongs_to_many :categories, :join_table => 'pages_categories'

  belongs_to_image        :image
  has_many :page_images,  :order => 'position ASC'
  has_many :images,
           :through => :page_images,
           :order => 'position ASC',
           :conditions => '`page_images`.`primary` = 0'

  has_many :comments, :class_name => 'PageComment', :dependent => :destroy
  has_many :files, :class_name => 'PageFile', :dependent => :destroy, :order => :position

  acts_as_list :scope => :parent_page
  acts_as_tree :foreign_key => :parent_page_id
  acts_as_taggable

  localizable do
    attribute :name
    attribute :body
    attribute :excerpt
    attribute :headline
    attribute :boxout

    # Get attributes from the template configuration
    PagesCore::Templates::TemplateConfiguration.all_blocks.each do |block|
      attribute block
    end
  end

  # Page status labels
  STATUS_LABELS         = ["Draft", "Reviewed", "Published", "Hidden", "Deleted"]
  AUTOPUBLISH_FUZZINESS = 2.minutes

  validates_format_of     :unique_name, :with => /^[\w\d_\-]+$/, :allow_nil => true, :allow_blank => true
  validates_uniqueness_of :unique_name, :allow_nil => true, :allow_blank => true

  validate do |page|
    page.template ||= page.default_template
  end

  attr_accessor :image_url, :image_description

  before_save do |page|
    page.published_at ||= Time.now
    page.autopublish = (page.published_at > Time.now) ? true : false

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
    page.delta = true
  end

  # Update primary image status
  after_save do |page|
    if page.image_id_changed?
      if page.image_id?
        # Update existing image
        if page_image = page.page_images.first(:conditions => {:image_id => page.image_id})
          page_image.update_attribute(:primary, true)

        # ..or create a new one
        else
          page.page_images.create(:image_id => page.image_id, :primary => true)
        end
      end
    end
  end

  define_index do
    # Fields
    indexes localizations.body,                   :as => :localization_bodies
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

    set_property :delta => :delayed
    set_property :group_concat_max_len => 16.megabytes
  end

  scope :published, lambda { where(:status => 2, :autopublish => false) }

  # ---- CLASS METHODS ------------------------------------------------------

  class << self

    # Finds page with unique name
    def find_unique(name)
      find_by_unique_name(name.to_s)
    end

    # Finds pages due for auto publishing and publishes them.
    def autopublish!(options={})
      timestamp  = Time.now + (options[:fuzziness] || AUTOPUBLISH_FUZZINESS)
      pages      = self.find(:all, :conditions => ['autopublish = 1 AND published_at < ?', timestamp])
      pages.each {|p| p.update_attribute(:autopublish, false)}
    end

    # Finds pages at the root level. See <tt>Page.get_pages</tt> for options, this is equal to <tt>Page.get_pages(:parent => :root, ..)</tt>.
    def root_pages(options={})
      options[:parent] ||= :root
      Page.get_pages(options)
    end

    # Finds all news pages (pages with the news_page bit on).
    #
    # === Parameters
    # * <tt>:locale</tt> - Set locale for the resulting pages.
    def news_pages(options={})
      ps = Page.find(:all, :conditions => ['news_page = 1 AND status < 4'], :order => 'published_at ASC')
      if options.has_key?(:language)
        options[:locale] = options[:language]
        options.delete(:language)
        logger.warn "DEPRECEATED: Option :language is deprecated, use :locale"
      end
      if options[:locale]
        ps = ps.map{|p| p.locale = options[:locale]; p}
      end
      ps
    end

    # Are there any news pages?
    def news_pages?
      (Page.count(:all, :conditions => ['news_page = 1 AND status < 4']) > 0) ? true : false
    end

    # Find a page by slug and locale
    def find_by_slug_and_locale(slug, locale)
      locale = locale.to_s
      slug   = slug.to_s

      # Search legacy slug localizations
      if localization = Localization.find(
          :first,
          :conditions => ['name = "slug" AND localizable_type = ? AND body = ? AND locale = ?', self.to_s, slug, locale]
        )
        page = localization.localizable

      # Search page names
      else
        localizations = Localization.find(
          :all,
          :conditions => [ "name = 'name' AND localizable_type = '#{self.to_s}' AND locale = ?", locale]
        )
        localizations = localizations.select{|tb| Page.string_to_slug( tb.body ) == slug}
        if localizations.length > 0
          page = localizations.first.localizable
        end
      end
      page ? page.localize(locale) : nil
    end

    # Convert a string to an URL friendly slug
    def string_to_slug(string)
      slug = string.downcase.gsub(/[^\w\s]/,'')
      slug = slug.split( /[^\w\d\-]+/ ).compact.join( "_" )
    end

    # Find all published and feed enabled pages
    def enabled_feeds(locale, options={})
      conditions = (options[:include_hidden]) ? 'feed_enabled = 1 AND status IN (2,3)' : 'feed_enabled = 1 AND status = 2'
      Page.find(:all, :conditions => conditions).collect{|p| p.locale = locale.to_s; p}
    end

    def status_labels_for_options
      labels = Array.new
      Page::STATUS_LABELS.each_index{|i| labels << [Page::STATUS_LABELS[i],i]}
      labels
    end

  end



  # ---- INSTANCE METHODS ---------------------------------------------------

  def tag_list=(tag_list)
    tag_with(tag_list)
  end

  alias_method :acts_as_tree_parent, :parent

  # Get this page's parent page.
  def parent
    parent = acts_as_tree_parent
    if parent && parent.kind_of?(Page)
      parent.localize(self.locale)
    else
      parent
    end
  end
  alias_method :parent_page, :parent

  alias_method :acts_as_tree_ancestors, :ancestors

  # Finds this page's ancestors
  def ancestors
    ancestors = self.acts_as_tree_ancestors
    if self.locale
      ancestors = ancestors.map{|a| a.localize(self.locale) }
    end
    ancestors
  end

  def is_ancestor?(page)
    page.ancestors.include?(self)
  end

  def is_or_is_ancestor?(page)
    (page == self || self.is_ancestor?(page)) ? true : false
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
    (self.excerpt? && self.body?) ? true : false
  end

  # Does this page have any files?
  def files?
    (!self.files.empty?) ? true : false
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
      tpl = PagesCore::Templates.names.select{ |t| t.match(Regexp.new('^'+Regexp.quote(base_template)+'_?(post|page|subpage|item)')) }.first rescue nil
      # Try to singularize the base template if the subtemplate could not be found.
      unless tpl and base_template == ActiveSupport::Inflector::singularize(base_template)
        tpl = PagesCore::Templates.names.select{ |t| t.match(Regexp.new('^'+Regexp.quote(ActiveSupport::Inflector::singularize(base_template)))) }.first rescue nil
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

  # Does this page have an image?
  def image?
    self.image_id?
  end

  # Get subpages
  def pages(options=nil)
    if options.kind_of?(Hash)
      # TODO: Remove this when the deprecated methods are removed.
      get_pages_with_hash(options)
    else
      subpages = self.children.published.order(self.news_page? ? "pinned DESC, #{self.content_order}" : self.content_order)
      if self.locale?
        subpages = subpages.localized(self.locale)
      end
      subpages
    end
  end

  # Count subpages
  def count_pages(options={})
    options[:parent] ||= self.id
    options[:order]  ||= self.content_order
    options[:locale] ||= self.locale if self.locale
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
    while root_page.parent
      root_page = root_page.parent
    end
    root_page
  end

  def is_child_of(page)
    compare = self
    while compare.parent
      compare = compare.parent
      return true if compare == page
    end
    return false
  end

  # Get sibling by offset (most likely +1 or -1)
  def sibling_by_offset(offset, options={})
    return nil unless self.parent
    siblings = self.parent.pages(options)
    raise "self not found in collection" unless siblings.include? self
    index    = siblings.index(self) + offset
    (index >= 0 && index < siblings.length) ? siblings[index] : nil
  end

  # Get the next sibling
  def next_sibling(options={})
    sibling_by_offset(1, options)
  end

  # Get the previous
  def previous_sibling(options={})
    sibling_by_offset(-1, options)
  end

  # Return the status of the page as a string
  def status_label
    STATUS_LABELS[self.status]
  end

  # Set the page status
  def set_status(new_status)
    new_status = new_status.to_i if new_status.kind_of?(String) && new_status.match(/^[\d]+$/)
    if( new_status.kind_of?(String) || new_status.kind_of?(Symbol))
      new_status = new_status.to_s
      index = STATUS_LABELS.collect{|l| l.downcase}.index(new_status.downcase)
      write_attribute(:status, index) unless index.nil?
    elsif new_status.kind_of?(Numeric)
      write_attribute(:status, new_status.to_i)
    end
  end

  def template=(template_file)
    write_attribute('template', template_file)
  end

  def extended?
    self.excerpt?
  end

  def blank?
    !self.body?
  end

  # Get publication date, which defaults to the creation date
  def published_at
    self[:published_at] ||= self.created_at
  end

  # Returns boolean true if page has a valid redirect
  def redirects?
    return false if self.redirect_to == "0"
    return true  if self.redirect_to.kind_of?(String) and !self.redirect_to.strip.empty?
    return true  if self.redirect_to.kind_of?(Hash)   and !self.redirect_to.empty?
    return false
  end

  # Take the given options and merge self.redirect_to with them. If self.redirect_to is a string, nothing will be merged.
  def redirect_to_options(options={})
    options.symbolize_keys!
    redirect = self.redirect_to
    if redirect.kind_of?(Hash)
      redirect.symbolize_keys!
      options.delete :language unless redirect.has_key?(:language)
      redirect.delete :language if options.has_key?(:language)
      redirect = options.merge(redirect)
    end
    redirect
  end

  # Returns true if this page's children is reorderable
  def reorderable_children?
    (!self.content_order? || (self.content_order =~ /position/)) ? true : false
  end

  # Returns true if this page is reorderable
  def reorderable?
    (!self.parent || !self.parent.content_order? || (self.parent.content_order =~ /position/)) ? true : false
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
        author = User.exists?(:email => attributes['author_email']) ? User.find_by_email(attributes['author_email'].to_s): self.author
        attributes.delete('author_email')
      else
        author = self.author
      end
      page = Page.new.localize(self.locale)
      page.author = author
      if page.update_attributes(attributes)
        created_pages << page
      end
    end
    created_pages
  end

  def method_missing(method_name, *args)
    name = method_name.to_s
    # Booleans
    if(n = name.match(/(.*)\?/))
      downcase_labels = STATUS_LABELS.collect{|l| l.downcase }
      if downcase_labels.include?(n[1].downcase)
        return (self.status == downcase_labels.index(n[1].downcase)) ? true : false
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
      names = names.to_s.split(/[\s]*,[\s]*/).reject{|n| n.blank?}
      if names.length > 0
        categories = names.map do |name|
          cat = Category.exists?(:name => name) ? Category.find_by_name(name) : Category.create(:name => name)
        end
      end
      self.categories = categories
    end
  end

  # Does this page have images?
  def images?
    self.images.count > 0
  end

  # Is this page published?
  def published?
    (self.status == 2 && !self.autopublish?) ? true : false
  end

  def slug
    self.class.string_to_slug(self.name.to_s)
  end

  def to_param
    "#{id}-#{self.slug}"
  end

  def content_order
    self[:content_order] || 'position'
  end

  def empty?
    ((self.body.to_s + self.excerpt.to_s).strip.empty?) ? true : false
  end

  alias_method :ar_to_xml, :to_xml
  def to_xml(options = {})
    default_except = [:comments_count, :byline, :delta, :last_comment_at, :image_id]
    options[:except] = (options[:except] ? options[:except] + default_except : default_except)
    ar_to_xml(options) do |xml|
      self.all_fields.each do |localizable_name|
        xml.tag!(localizable_name.to_sym) do |field|
          self.languages_for_field(localizable_name).each do |language|
            field.tag!(language.to_sym, self.get_localization(localizable_name, :language => language).to_s)
          end
        end
      end
      self.tags.to_xml(:builder => xml, :skip_instruct => true, :only => [:name])
      if options[:images]
        xml.images do |images_xml|
          self.page_images.each{|page| page.to_xml(:builder => images_xml, :skip_instruct => true, :only => [:image_id, :primary])}
        end
      end
      if options[:comments]
        xml.comments do |comments_xml|
          self.comments.each{|comment| comment.to_xml(:except => [:page_id], :builder => comments_xml, :skip_instruct => true)}
        end
      end
      if options[:pages]
        subpages = (options[:pages] == :all) ? self.pages(:all => true) : self.pages
        xml.pages do |pages_xml|
          self.pages.each{|page| page.to_xml(options.merge({:builder => pages_xml, :skip_instruct => true}))}
        end
      end
    end
  end

end
