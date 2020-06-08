# frozen_string_literal: true

class PageCategory < ActiveRecord::Base
  belongs_to :page
  belongs_to :category
  validates :page_id, :category_id, presence: true
end
