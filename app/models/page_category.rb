# frozen_string_literal: true

class PageCategory < ApplicationRecord
  belongs_to :page
  belongs_to :category
end
