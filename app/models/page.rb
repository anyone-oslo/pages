# encoding: utf-8

class Page < ActiveRecord::Base
  include PagesCore::HumanizableParam
  include PagesCore::PageTree
  include PagesCore::SearchablePage
  include PagesCore::Sweepable
  include PagesCore::Taggable
  include PagesCore::Templateable

  belongs_to :author, class_name: "User", foreign_key: :user_id

  has_and_belongs_to_many :categories, join_table: "pages_categories"

  belongs_to_image :image
  belongs_to_image :meta_image, class_name: "Image"

  has_many :page_images, -> { order("position") }

  has_many :images,
           -> { where("`page_images`.`primary` = ?", false).order("position") },
           through: :page_images

  has_many :comments,
           class_name: "PageComment",
           dependent: :destroy

  has_many :page_files,
           -> { order("position ASC") },
           class_name: "PageFile",
           dependent: :destroy

  acts_as_list scope: :parent_page

  localizable do
    attribute :name
    attribute :body
    attribute :excerpt
    attribute :headline
    attribute :boxout

    attribute :meta_description
    attribute :open_graph_title
    attribute :open_graph_description

    dictionary -> { PagesCore::Templates::TemplateConfiguration.all_blocks }
  end

  validates_format_of :redirect_to,
                      with: %r{\A(/|https?://)},
                      allow_nil: true,
                      allow_blank: true

  validates_format_of :unique_name,
                      with: /\A[\w\d_\-]+\z/,
                      allow_nil: true,
                      allow_blank: true

  validates_uniqueness_of :unique_name, allow_nil: true, allow_blank: true

  validates :template, presence: true
  validates :content_order, presence: true
  validates :published_at, presence: true

  before_validation :published_at
  before_validation :set_autopublish
  before_validation :set_content_order
  after_save :ensure_page_images_contains_primary_image
  after_save :queue_autopublisher
  after_save ThinkingSphinx::RealTime.callback_for(:page)

  scope :by_date,    -> { order("published_at DESC") }
  scope :published,  -> { where(status: 2, autopublish: false) }
  scope :visible,    -> { where("status < 4") }
  scope :news_pages, -> { visible.where(news_page: true) }
  scope :pinned,     -> { where(pinned: true) }

  class << self
    def archive_finder
      PagesCore::ArchiveFinder.new(all, timestamp: :published_at)
    end

    # Find all published and feed enabled pages
    def enabled_feeds(locale, options = {})
      conditions = (options[:include_hidden]) ? "status IN (2,3)" : "status = 2"
      Page.where(feed_enabled: true).where(conditions).localized(locale)
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

    def order_by_tags(tags)
      joins(
        "LEFT JOIN taggings ON taggings.taggable_id = pages.id AND " \
          "taggable_type = \"Page\"",
        "LEFT JOIN tags ON tags.id = taggings.tag_id AND tags.id IN (" +
          tags.map(&:id).join(",") +
          ")"
      )
        .group("pages.id, localizations.id")
        .reorder("COUNT(tags.id) DESC, position ASC")
    end
  end

  def comments_closed_after_time?
    if PagesCore.config.close_comments_after.nil?
      false
    else
      (Time.now - published_at) > PagesCore.config.close_comments_after
    end
  end

  def comments_allowed?
    if self.comments_closed_after_time?
      false
    else
      self[:comments_allowed]
    end
  end

  def extended?
    excerpt? && body?
  end

  def empty?
    !body? && !excerpt?
  end
  alias_method :blank?, :empty?

  def excerpt_or_body
    excerpt? ? excerpt : body
  end

  def image
    super.try { |i| i.localize(locale) }
  end

  def images
    super.in_locale(locale)
  end

  def page_images
    super.in_locale(locale)
  end

  def files
    page_files.in_locale(locale)
  end

  def headline_or_name
    headline? ? headline : name
  end

  # Does this page have an image?
  def image?
    self.image_id?
  end

  # Get subpages
  def pages(_options = nil)
    if self.locale?
      subpages.published.localized(locale)
    else
      subpages.published
    end
  end

  def subpages
    children.order(pinned_content_order)
  end

  # Return the status of the page as a string
  def status_label
    self.class.status_labels[status]
  end

  def flag_as_deleted!
    update(status: 4)
  end

  # Get publication date, which defaults to the creation date
  def published_at
    if self.created_at?
      self[:published_at] ||= created_at
    else
      self[:published_at] ||= Time.now
    end
  end

  # Returns boolean true if page has a valid redirect
  def redirects?
    self.redirect_to?
  end

  def redirect_path(params = {})
    path = redirect_to.dup
    if path.start_with? "/"
      params.each do |key, value|
        unless value.is_a?(String) || value.is_a?(Symbol)
          fail "redirect_url param must be a string or a symbol"
        end
        path.gsub!("/:#{key}", "/#{value}")
      end
    end
    path
  end

  # Returns true if this page's children is reorderable
  def reorderable_children?
    !self.content_order? || content_order =~ /position/
  end

  # Returns true if this page is reorderable
  def reorderable?
    !parent || !parent.content_order? || parent.content_order =~ /position/
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
    humanized_param(name)
  end

  def content_order
    self[:content_order] || "position"
  end

  private

  def ensure_page_images_contains_primary_image
    return if !image_id? || !image_id_changed?
    page_image = page_images.where(image_id: image_id).first
    if page_image
      page_image.update(primary: true)
    else
      page_images.create(image_id: image_id, primary: true)
    end
  end

  def pinned_content_order
    self.news_page? ? "pages.pinned DESC, #{content_order}" : content_order
  end

  def set_autopublish
    self.autopublish = published_at? && published_at > Time.now
    true
  end

  def set_content_order
    self[:content_order] ||= "position"
  end

  def queue_autopublisher
    Autopublisher.queue! if self.autopublish?
  end
end
