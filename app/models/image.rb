# frozen_string_literal: true

class Image < ApplicationRecord
  include DynamicImage::Model
  include PagesCore::Sweepable

  validate :ensure_max_size, on: :create

  localizable do
    attribute :alternative
    attribute :caption
  end

  private

  def ensure_max_size
    return unless real_width? && real_height?
    return if real_width * real_height <= 48_000_000

    errors.add(:data, "is too large")
  end
end
