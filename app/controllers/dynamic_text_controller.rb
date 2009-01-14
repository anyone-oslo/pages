require 'RMagick'

# Dynamic text images.
#
# Setup:
# Put your fonts in /fonts. Set up the text formats in config/initializers/pages.rb:
#
#   module Pages::DynamicText
#     TEXT_FORMATS = {
#       :menu => {
#         :font             => 'PLAST28_.ttf',
#         :font_size        => 23,
#         :max_width        => 200,
#         :color            => "#CCD5BE",
#         :background_color => "#032726"
#       }
#     }
#   end
#
# Usage:
#   image_tag(dynamic_text_path(:text => "Menu item", :format => :menu), :alt => "Menu item")
#
class DynamicTextController < ApplicationController

    session :off
    caches_page :show

    def render_dynamic_text(text, options={}, &block)
        options[:crop] = true unless options.has_key?(:crop)
		if RAILS_ENV == "production"
            options[:margin] ||= 10
        else
            options[:margin] ||= 3
        end
        image = Magick::Image.read("caption:#{text.to_s}") {
            self.size = options[:max_width]
            block.call(self) if block_given?
        }.first
		if RAILS_ENV == "production"
            image.crop!(Magick::NorthWestGravity, 4, 0, image.bounding_box.width + options[:margin], image.rows) if options[:crop]
        else
            image.crop!(Magick::NorthWestGravity, image.bounding_box.width + options[:margin], image.rows) if options[:crop]
        end
        image
    end

    def show
        text = params[:text]
        text_format = Pages::DynamicText::TEXT_FORMATS[params[:text_format].to_sym]
        font_path = File.join(File.dirname(__FILE__), '../../../../../fonts', text_format[:font])

        text_image = render_dynamic_text(text, text_format) do |img|
            img.fill             = text_format[:color]
            img.background_color = text_format[:background_color]
            img.pointsize        = text_format[:font_size]
            img.antialias        = true
            img.font             = font_path
        end
        
        image_data = text_image.to_blob{ |img| img.format = "PNG" }
		send_data( 
			image_data, 
			:filename    => "#{text}.png",
			:type        => 'image/png', 
			:disposition => 'inline'
		)
    end
end
