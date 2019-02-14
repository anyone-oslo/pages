module PagesCore
  module Frontend
    class PageFilesController < ::FrontendController
      include PagesCore::AttachmentsHelper

      before_action :find_page_file, only: %i[show]

      def show
        if stale?(etag: @page_file, last_modified: @page_file.updated_at)
          redirect_to attachment_path(@page_file.attachment)
        end
      end

      private

      def find_page_file
        @page_file = PageFile.find(params[:id])
      end
    end
  end
end
