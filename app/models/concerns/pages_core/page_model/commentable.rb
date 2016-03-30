# encoding: utf-8

module PagesCore
  module PageModel
    module Commentable
      extend ActiveSupport::Concern

      included do
        has_many :comments, class_name: "PageComment", dependent: :destroy
      end

      def comments_closed_after_time?
        if PagesCore.config.close_comments_after.nil?
          false
        else
          (Time.now.utc - published_at) > PagesCore.config.close_comments_after
        end
      end

      def comments_allowed?
        if comments_closed_after_time?
          false
        else
          self[:comments_allowed]
        end
      end
    end
  end
end
