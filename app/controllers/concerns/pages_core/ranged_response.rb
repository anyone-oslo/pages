# frozen_string_literal: true

module PagesCore
  module RangedResponse
    extend ActiveSupport::Concern

    def send_ranged_data(data, options = {})
      response.header["Content-Length"] = data.length
      response.header["Accept-Ranges"] = "bytes"

      content_range_headers(data.length) if ranged_request?

      send_data(ranged_data(data),
                options.merge(status: ranged_request? ? 206 : 200))
    end

    private

    def content_range(length)
      Rack::Utils.byte_ranges(request.headers, length)[0]
    end

    def content_range_headers(size)
      bytes = content_range(size)
      response.header["Content-Length"] = bytes.end - bytes.begin + 1
      response.header["Content-Range"] =
        "bytes #{bytes.begin}-#{bytes.end}/#{size}"
    end

    def ranged_data(data)
      return data unless ranged_request?

      data[content_range(data.length)]
    end

    def ranged_request?
      request.headers["HTTP_RANGE"]
    end
  end
end
