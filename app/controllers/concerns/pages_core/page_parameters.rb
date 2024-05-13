# frozen_string_literal: true

module PagesCore
  module PageParameters
    extend ActiveSupport::Concern

    def page_attachment_attributes
      { page_images_attributes: %i[id position image_id primary _destroy],
        page_files_attributes: %i[id position attachment_id _destroy] }
    end

    def page_content_attributes
      locales = PagesCore.config.locales&.keys || [I18n.default_locale]
      [page_static_attributes,
       PagesCore::Templates::TemplateConfiguration.all_blocks,
       :path_segment,
       (PagesCore::Templates::TemplateConfiguration
                  .localized_blocks + %i[path_segment])
         .index_with { locales },
       page_attachment_attributes]
    end

    def page_static_attributes
      %i[template user_id status feed_enabled published_at redirect_to
         news_page unique_name pinned parent_page_id serialized_tags
         meta_image_id starts_at ends_at all_day]
    end
  end
end
