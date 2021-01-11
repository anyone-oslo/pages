# frozen_string_literal: true

class Image < ApplicationRecord
  include DynamicImage::Model
  include PagesCore::Sweepable

  validate :ensure_max_size, on: :create

  localizable do
    attribute :alternative
    attribute :caption
  end

  def byline
    ActiveSupport::Deprecation.warn "Image#byline is deprecated, use #caption"
    caption
  end

  def byline?
    ActiveSupport::Deprecation.warn "Image#byline? is deprecated, use #caption?"
    caption?
  end

  def byline=(new_caption)
    ActiveSupport::Deprecation.warn "Image#byline= is deprecated, use #caption="
    self.caption = new_caption
  end

  private

  def ensure_max_size
    return if real_width * real_height <= 48_000_000

    errors.add(:data, "is too large")
  end
end
