# encoding: utf-8

class PageComment < ActiveRecord::Base
  include PagesCore::Sweepable

  belongs_to :page, counter_cache: :comments_count
  attr_accessor :invalid_captcha

  def valid_captcha?
    (invalid_captcha) ? false : true
  end

  after_create do |page_comment|
    if page_comment.page && page_comment.valid?
      page_comment.page.update(last_comment_at: page_comment.created_at)
    end
  end
end
