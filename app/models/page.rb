class Page < ActiveRecord::Base
  include PagesCore::HumanizableParam
  include PagesCore::Sweepable
  include PagesCore::Taggable

  include PagesCore::PageModel::Autopublishable
  include PagesCore::PageModel::Images
  include PagesCore::PageModel::Localizable
  include PagesCore::PageModel::Pathable
  include PagesCore::PageModel::Redirectable
  include PagesCore::PageModel::Sortable
  include PagesCore::PageModel::Status
  include PagesCore::PageModel::Tree
  include PagesCore::PageModel::Templateable

  belongs_to :author, class_name: "User", foreign_key: :user_id, optional: true

  has_many :page_categories, dependent: :destroy
  has_many :categories, through: :page_categories

  has_many :page_files,
           -> { order("position ASC") },
           class_name: "PageFile",
           dependent: :destroy

  validates(:unique_name,
            format: { with: /\A[\w\d_\-]+\z/,
                      allow_nil: true,
                      allow_blank: true },
            uniqueness: { allow_nil: true, allow_blank: true })

  validates :template, presence: true
  validates :published_at, presence: true

  before_validation :published_at

  scope :by_date,       -> { order("published_at DESC") }
  scope :by_updated_at, -> { order("updated_at DESC") }
  scope :published,     -> { where(status: 2, autopublish: false) }
  scope :hidden,        -> { where(status: 3) }
  scope :deleted,       -> { where(status: 4) }
  scope :visible,       -> { where("status < 4") }
  scope :news_pages,    -> { visible.where(news_page: true) }
  scope :pinned,        -> { where(pinned: true) }

  class << self
    def archive_finder
      PagesCore::ArchiveFinder.new(all, timestamp: :published_at)
    end

    # Find all published and feed enabled pages
    def enabled_feeds(locale, options = {})
      conditions = options[:include_hidden] ? "status IN (2,3)" : "status = 2"
      Page.where(feed_enabled: true).where(conditions).localized(locale)
    end
  end

  def empty?
    !body? && !excerpt?
  end
  alias blank? empty?

  def excerpt_or_body
    excerpt? ? excerpt : body
  end

  def extended?
    excerpt? && body?
  end

  def files
    page_files.in_locale(locale)
  end

  def headline_or_name
    headline? ? headline : name
  end

  def move(parent:, position:)
    Page.transaction do
      update(parent: parent) unless self.parent == parent
      insert_at(position)
    end
  end

  # Get publication date, which defaults to the creation date
  def published_at
    self[:published_at] ||= if created_at?
                              created_at
                            else
                              Time.now.utc
                            end
  end

  def to_param
    humanized_param(name)
  end
end
