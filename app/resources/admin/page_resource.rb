# frozen_string_literal: true

module Admin
  class PageResource
    include Alba::Resource
    include Rails.application.routes.url_helpers
    include PagesCore::PagePathHelper
    include DynamicImage::Helper

    attributes :id, :starts_at, :ends_at, :all_day, :status, :published_at,
               :pinned, :template, :unique_name, :feed_enabled, :news_page,
               :user_id, :redirect_to

    has_many :page_images, resource: Admin::PageImageResource
    has_many :page_files, resource: Admin::PageFileResource

    attribute :blocks do
      PagesCore::Templates::TemplateConfiguration.all_blocks
                                                 .index_with do |attr|
        if object.template_config.block(attr)[:localized]
          localized_attribute(object, attr)
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

    attribute :urls do
      if object.id?
        localized_objects.filter(&:name?).each_with_object({}) do |p, obj|
          obj[p.locale] = page_path(p.locale, p)
          obj
        end
      else
        {}
      end
    end

    attribute :enabled_tags do
      object.tags.map(&:name)
    end

    attribute :tags_and_suggestions do
      Tag.tags_and_suggestions_for(object, limit: 20)
         .map(&:name)
    end

    attribute :meta_image do
      image_uploader(object.meta_image)
    end

    attribute :path_segment do
      localized_attribute(object, :path_segment)
    end

    attribute :ancestors do
      object.ancestors.map do |p|
        { id: p.id,
          name: localized_attribute(p, :name),
          path_segment: localized_attribute(p, :path_segment) }
      end
    end

    private

    def image_uploader(image)
      return { src: nil, image: nil } unless image

      { src: dynamic_image_path(image, size: "500x"),
        image: ::Admin::ImageResource.new(image).to_hash }
    end

    def localized_objects
      object.locales.map { |l| object.localize(l) }
    end

    def localized_attribute(record, attr)
      record.locales.index_with do |locale|
        record.localize(locale).send(attr)
      end
    end
  end
end
