# encoding: utf-8

class Page < ActiveRecord::Base
  include Deprecations::DeprecatedPageFinders
  include PagesCore::HumanizableParam
  include PagesCore::PageTree
  include PagesCore::Taggable
  include PagesCore::Templateable

  serialize :redirect_to

  belongs_to :author, class_name: "User", foreign_key: :user_id

  has_and_belongs_to_many :categories, join_table: 'pages_categories'

  belongs_to_image :image

  has_many :page_images, order: 'position ASC'

  has_many :images,
           through:    :page_images,
           order:      'position ASC',
           conditions: '`page_images`.`primary` = 0'

  has_many :comments,
           class_name: 'PageComment',
           dependent:  :destroy

  has_many :files,
           class_name: 'PageFile',
           dependent:  :destroy,
           order:      :position

  acts_as_list scope: :parent_page

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

  validates_format_of     :unique_name, with: /^[\w\d_\-]+$/, allow_nil: true, allow_blank: true
  validates_uniqueness_of :unique_name, allow_nil: true, allow_blank: true

  before_validation :published_at
  before_validation :set_autopublish
  before_save       :set_delta
  after_save        :ensure_page_images_contains_primary_image

  define_index do
    # Fields
    indexes localizations.body,              as: :localization_bodies
    indexes categories.name,                 as: :category_names
    indexes tags.name,                       as: :tag_names
    indexes [author.realname, author.email], as: :author_name
    indexes [comments.name, comments.body],  as: :comments

    # Attributes
    has published_at, created_at, updated_at
    has user_id, parent_page_id
    has status, template
    has autopublish, feed_enabled
    has categories(:id), as: :category_ids
    has tags(:id), as: :tag_ids

    set_property delta: :delayed
    set_property group_concat_max_len: 16.megabytes
  end

  scope :published,  -> { where(status: 2, autopublish: false) }
  scope :visible,    -> { where('status < 4') }
  scope :news_pages, -> { visible.where(news_page: true) }

  class << self

    def archive_finder
      PagesCore::ArchiveFinder.new(scoped, timestamp: :published_at)
    end

    # Finds pages due for auto publishing and publishes them.
    def autopublish!(options={})
      Page.where('autopublish = ? AND published_at <?', true, (Time.now + 2.minutes)).each do |p|
        p.update_attributes(autopublish: false)
      end
    end

    # Find all published and feed enabled pages
    def enabled_feeds(locale, options={})
      conditions = (options[:include_hidden]) ? 'feed_enabled = 1 AND status IN (2,3)' : 'feed_enabled = 1 AND status = 2'
      Page.find(:all, conditions: conditions).collect{|p| p.locale = locale.to_s; p}
    end

    def status_labels
      {
        0 => "Draft",
        1 => "Reviewed",
        2 => "Published",
        3 => "Hidden",
        4 => "Deleted"
      }
    end
  end

  def extended?
    excerpt? && body?
  end

  def empty?
    !body? && !excerpt?
  end
  alias :blank? :empty?

  def excerpt_or_body
    excerpt? ? excerpt : body
  end

  def headline_or_name
    headline? ? headline : name
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

  # Return the status of the page as a string
  def status_label
    self.class.status_labels[self.status]
  end

  def flag_as_deleted!
    update_attributes(status: 4)
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
    !self.content_order? || self.content_order =~ /position/
  end

  # Returns true if this page is reorderable
  def reorderable?
    !self.parent || !self.parent.content_order? || self.parent.content_order =~ /position/
  end

  def draft?
    status == 0
  end

  def reviewed?
    status == 1
  end

  def published?
    status == 2 && !autopublish?
  end

  def hidden?
    status == 3
  end

  def deleted?
    status == 4
  end

  def to_param
    humanized_param(self.name)
  end

  def content_order
    self[:content_order] || 'position'
  end

  def to_xml(options = {})
    # Always skip these
    options[:except] = [:comments_count, :byline, :delta, :last_comment_at, :image_id] + Array(options[:except])

    super(options) do |xml|

      # Localizations
      self.template_config.enabled_blocks.each do |localizable_name, block_options|
        xml.tag!(localizable_name.to_sym) do |field|
          self.locales.each do |locale|
            field.tag!(locale.to_sym, self.localize(locale).send(localizable_name))
          end
        end
      end

      # Tags
      self.tags.to_xml(builder: xml, skip_instruct: true, only: [:name])

      # Images
      if options[:images]
        xml.images do |images_xml|
          self.page_images.each{ |page_image| page_image.to_xml(builder: images_xml, skip_instruct: true, only: [:image_id, :primary]) }
        end
      end

      # Comments
      if options[:comments]
        xml.comments do |comments_xml|
          self.comments.each{|comment| comment.to_xml(except: [:page_id], builder: comments_xml, skip_instruct: true)}
        end
      end

      # Subpages
      if options[:pages]
        subpages = (options[:pages] == :all) ? self.children : self.pages
        xml.pages do |pages_xml|
          self.pages.each{ |page| page.to_xml(options.merge({builder: pages_xml, skip_instruct: true})) }
        end
      end
    end
  end

  private

  def ensure_page_images_contains_primary_image
    if image_id? && image_id_changed?
      if page_image = page_images.where(image_id: image_id).first
        page_image.update_attributes(primary: true)
      else
        page_images.create(image_id: image_id, primary: true)
      end
    end
  end

  def set_autopublish
    self.autopublish = published_at? && published_at > Time.now
    true
  end

  def set_delta
    delta = true
  end

end