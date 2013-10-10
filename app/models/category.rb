# encoding: utf-8

class Category < ActiveRecord::Base
  has_and_belongs_to_many :pages, join_table: 'pages_categories'
  validates_presence_of :name
  acts_as_list

  before_save :set_slug
  after_save :trigger_delta_indexing

  scope :by_name, -> { order("name ASC") }

  private

  def set_slug
    self.slug = name.downcase.gsub(/[^\w\s]/, '').split(/[^\w\d\-]+/).compact.join('-')
  end

  def trigger_delta_indexing
    pages.each do |page|
      page.update_attributes(delta: true)
    end
  end
end
