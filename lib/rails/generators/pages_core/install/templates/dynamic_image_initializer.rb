# encoding: utf-8

# Be sure to restart your web server when you modify this file.

# Unsharp mask by default
class DefaultFilterset < DynamicImage::Filterset
  def self.process(image)
    image = image.unsharp_mask(0.0, 1.0, 0.6, 0.05)
  end
end
