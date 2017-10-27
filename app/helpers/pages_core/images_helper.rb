module PagesCore
  module ImagesHelper
    include DynamicImage::Helper

    def dynamic_image_tag(record_or_array, options = {})
      super(
        record_or_array,
        extract_alt_text(record_or_array).merge(options)
      )
    end

    def original_dynamic_image_tag(record_or_array, options = {})
      super(
        record_or_array,
        extract_alt_text(record_or_array).merge(options)
      )
    end

    def uncropped_dynamic_image_tag(record_or_array, options = {})
      super(
        record_or_array,
        extract_alt_text(record_or_array).merge(options)
      )
    end

    private

    def extract_alt_text(record_or_array)
      record = extract_dynamic_image_record(record_or_array)
      return {} unless record.alternative?
      { alt: record.alternative }
    end
  end
end
