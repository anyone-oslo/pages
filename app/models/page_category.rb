# encoding: utf-8

class PageCategory < ActiveRecord::Base
  belongs_to :page
  belongs_to :category
  validates :page_id, :category_id, presence: true
end
