# Dynamic text images.
#
# Setup:
# Put your fonts in /fonts. Set up the text formats in config/initializers/pages.rb:
#
#   module PagesCore::DynamicText
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
class DynamicTextController < FrontendController

    session :off
    caches_page :show

    def render_dynamic_text(text, options={}, &block)
		text = text.gsub('&#47;', '/') # Hack to circumvent the Apache encoded slashes bug
		text = text.gsub('ENCODEDQUESTION', '?')
		text = text.gsub('ENCODEDHASH', '#')
		options[:crop] = true unless options.has_key?(:crop)
		options[:padding_right] = options[:margin] if options.has_key?(:margin)
		options[:padding_right] ||= 3
 		image = Magick::Image.read("caption:#{text.to_s}") {
			self.size = options[:max_width]
			block.call(self) if block_given?
		}.first
        image.crop!(Magick::NorthWestGravity, image.bounding_box.width + options[:padding_right], image.rows) if options[:crop]
        image
    end

    def show
        text = params[:text]
        text_format = PagesCore::DynamicText::TEXT_FORMATS[params[:text_format].to_sym]
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
