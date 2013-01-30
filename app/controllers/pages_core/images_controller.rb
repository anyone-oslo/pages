# encoding: utf-8

class PagesCore::ImagesController < DynamicImage::ImagesController
  caches_page :view_image

  def render_missing_image

    # If :image_fallback_url is set, try grabbing the resource over HTTP
    if Rails.env.development? && PagesCore.config(:image_fallback_url)
      base_url = PagesCore.config.image_fallback_url.gsub(/\/$/, '')
      image_url = "#{base_url}#{request.path}"

      send_options = {
        :filename => request.path.split('/').last,
        :disposition => 'inline'
      }

      begin
        data = nil
        open(image_url) do |f|
          data = f.read
          send_options[:content_type] = f.content_type
          response.headers['Last-Modified'] = f.last_modified.httpdate
        end
        send_data(data, send_options)
      rescue
        render_error 404
      end

    # If not, render 404
    else
      render_error 404
    end
  end

end
