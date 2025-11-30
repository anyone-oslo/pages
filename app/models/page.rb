# frozen_string_literal: true

class Page < ApplicationRecord
  include PagesCore::HumanizableParam
  include PagesCore::SearchableDocument
  include PagesCore::Sweepable
  include PagesCore::Taggable

  include PagesCore::PageModel::Attachments
  include PagesCore::PageModel::Autopublishable
  include PagesCore::PageModel::DatedPage
  include PagesCore::PageModel::Images
  include PagesCore::PageModel::Localizable
  include PagesCore::PageModel::Pathable
  include PagesCore::PageModel::Redirectable
  include PagesCore::PageModel::Searchable
  include PagesCore::PageModel::Sortable
  include PagesCore::PageModel::Status
  include PagesCore::PageModel::Tree
  include PagesCore::PageModel::Templateable

  belongs_to :author,
             class_name: "User",
             foreign_key: :user_id,
             optional: true,
             inverse_of: :pages

  validates(:unique_name,
            format: { with: /\A[\w\d_-]+\z/,
                      allow_blank: true },
            uniqueness: { allow_blank: true })

  validates :template, presence: true
  validates :published_at, presence: true

  before_validation :published_at

  scope :by_date,       -> { order(published_at: :desc) }
  scope :by_updated_at, -> { order(updated_at: :desc) }
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

  def headline_or_name
    headline? ? headline : name
  end

  def move(parent:, position:)
    Page.transaction do
      update(parent:) unless self.parent == parent
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
    humanized_param(transliterated_name)
  end
end
