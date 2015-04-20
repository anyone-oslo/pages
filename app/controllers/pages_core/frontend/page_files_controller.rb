# encoding: utf-8

module PagesCore
  module Frontend
    class PageFilesController < ::FrontendController
      before_action :find_page_file, only: [:show, :edit, :update, :destroy]

      def show
        if !modified?(@page_file)
          render(text: "304 Not Modified", status: 304) && return
        end

        if @page_file.created_at?
          response.headers["Last-Modified"] = @page_file.created_at.httpdate
        end

        send_data(
          @page_file.data,
          filename:    @page_file.filename,
          type:        @page_file.content_type,
          disposition: "attachment"
        )
      end

      private

      def modified?(page_file)
        if_modified_since &&
          page_file.created_at? &&
          page_file.created_at > if_modified_since
      end

      def if_modified_since
        return nil unless request.env["HTTP_IF_MODIFIED_SINCE"]
        Time.rfc2822(request.env["HTTP_IF_MODIFIED_SINCE"])
      end

      def find_page_file
        @page_file = PageFile.find(params[:id])
      end
    end
  end
end
