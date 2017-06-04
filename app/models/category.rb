# encoding: utf-8

class Category < ActiveRecord::Base
  has_many :page_categories, dependent: :destroy
  has_many :pages, through: :page_categories
  validates :name, presence: true
  acts_as_list

  before_save :set_slug

  if const_defined?("ThinkingSphinx")
    after_save ThinkingSphinx::RealTime.callback_for(:pages, [:page])
  end

  scope :by_name, -> { order("name ASC") }

  private

  def set_slug
    self.slug = name.downcase
                    .gsub(/[^\w\s]/, "")
                    .split(/[^\w\d\-]+/)
                    .compact
                    .join("-")
  end
end
