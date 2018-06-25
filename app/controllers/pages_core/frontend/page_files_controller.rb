module PagesCore
  module Frontend
    class PageFilesController < ::FrontendController
      before_action :find_page_file, only: %i[show]

      def show
        if stale?(etag: @page_file, last_modified: @page_file.updated_at)
          send_data(@page_file.data,
                    filename: @page_file.filename,
                    type: @page_file.content_type,
                    disposition: "attachment")
        end
      end

      private

      def find_page_file
        @page_file = PageFile.find(params[:id])
      end
    end
  end
end
