# frozen_string_literal: true

module Admin
  class PageResource
    include Alba::Resource

    attributes :id, :starts_at, :ends_at, :all_day, :status, :published_at,
               :pinned, :template, :unique_name, :feed_enabled, :news_page,
               :redirect_to

    PagesCore::Templates::TemplateConfiguration.all_blocks.each do |attr|
      attribute attr do
        if object.template_config.block(attr)[:localized]
          localized_attribute(attr)
        else
          object.send(attr)
        end
      end
    end

    attribute :errors do
      object.errors.map do |e|
        { attribute: e.attribute,
          message: e.message }
      end
    end

    private

    def localized_attribute(attr)
      object.locales.index_with do |locale|
        object.localize(locale).send(attr)
      end
    end
  end
end
