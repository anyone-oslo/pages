class Image < ActiveRecord::Base
  include DynamicImage::Model

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
end
