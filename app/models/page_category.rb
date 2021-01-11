# frozen_string_literal: true

class PageCategory < ApplicationRecord
  belongs_to :page
  belongs_to :category
  validates :page_id, :category_id, presence: true
end
