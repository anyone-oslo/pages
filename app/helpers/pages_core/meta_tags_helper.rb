module PagesCore
  module MetaTagsHelper
    # Sets a default image to use for meta tags. Supports
    # both paths and Image objects.
    #
    #  default_meta_image image_path("facebook-share.png")
    #  default_meta_image root_page.image
    #
    def default_meta_image(*args)
      if args.any?
        @default_meta_image = args.first
      else
        @default_meta_image
      end
    end

    # Returns true if default meta image has been set.
    def default_meta_image?
      default_meta_image ? true : false
    end

    # Sets a description for meta tags.
    #
    #   meta_description "This is an awesome site"
    #
    def meta_description(*args)
      if args.any?
        @meta_description = args.first
      else
        description = @meta_description
        description ||= @page.meta_description if @page.try(&:meta_description?)
        description ||= @page.excerpt if @page && !@page.excerpt.empty?
        strip_tags(description)
      end
    end

    # Returns true if meta description has been set.
    def meta_description?
      meta_description.present?
    end

    # Sets an image to use for meta tags. Supports
    # both paths and Image objects.
    #
    #   meta_image image_path("facebook-share.png")
    #   meta_image @page.image
    #
    def meta_image(*args)
      if args.any?
        @meta_image = args.first
      else
        image = find_meta_image
        if image.is_a?(Image)
          dynamic_image_url(image, size: "1200x", only_path: false)
        else
          image
        end
      end
    end

    # Returns true if meta image has been set.
    def meta_image?
      meta_image.present? || default_meta_image?
    end

    # Sets keywords for meta tags.
    #
    #   meta_keywords "cialis viagra"
    #
    def meta_keywords(*args)
      if args.any?
        @meta_keywords = Array(args.first).join(", ")
      else
        keywords = @meta_keywords
        keywords ||= @page.tag_list if @page && @page.tags.any?
        strip_tags(keywords)
      end
    end

    # Returns true if meta keywords have been set.
    def meta_keywords?
      meta_keywords.present?
    end

    private

    def find_meta_image
      @meta_image ||
        @page.try(&:meta_image) ||
        @page.try(&:image) ||
        default_meta_image
    end
  end
end
