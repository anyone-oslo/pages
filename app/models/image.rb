# frozen_string_literal: true

class Image < ApplicationRecord
  include DynamicImage::Model
  include PagesCore::Sweepable

  validate :ensure_max_size, on: :create

  localizable do
    attribute :alternative
    attribute :caption
  end

  # Decorative images get an empty alt, which tells assistive technology to
  # skip them. Otherwise, blank alternative text returns nil and the alt
  # attribute is left out, so the missing text is flagged by accessibility
  # checkers rather than passed off as decorative.
  def alt_text
    return "" if decorative?

    alternative.presence
  end

  private

  def ensure_max_size
    return unless real_width? && real_height?
    return if real_width * real_height <= 48_000_000

    errors.add(:data, :image_too_big, count: 48)
  end
end
