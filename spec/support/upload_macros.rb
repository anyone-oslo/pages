# frozen_string_literal: true

module UploadMacros
  def uploaded_file(content, filename, content_type)
    tempfile = Tempfile.new
    tempfile.binmode
    tempfile.write(content)
    tempfile.rewind
    Rack::Test::UploadedFile.new(tempfile, content_type,
                                 original_filename: filename)
  end
end
