class PagesCore::ImagesController < DynamicImage::ImagesController
	caches_page :view_image

	def render_missing_image
		if RAILS_ENV == 'development' && PagesCore.config(:image_fallback_url)
			base_url = PagesCore.config.image_fallback_url.gsub(/\/$/, '')
			redirect_to "#{base_url}#{request.path}"
		else
			render_error 404
		end
	end

end