module PagesCore
  class FileEmbedder
    include ActionView::Helpers::AssetTagHelper

    attr_reader :files

    def initialize(files)
      @files = Array(files)
    end

    def to_html
      embed_files(files.map { |f| embed_file(f) })
    end

    def embed_files(embedded_files)
      embedded_files.join(", ")
    end

    def embed_file(file)
      content_tag(
        :a,
        file.name,
        class: "file",
        href: file_path(file)
      )
    end

    private

    def file_path(file)
      Rails.application.routes.url_helpers.page_file_path(
        file.locale,
        file.page,
        file
      )
    end
  end
end
