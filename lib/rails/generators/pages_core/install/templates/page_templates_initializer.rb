# encoding: utf-8

# Be sure to restart your web server when you modify this file.

# Templates configuration
PagesCore::Templates.configure do |config|
  # Default configuration for all templates
  config.default do |default|
    # The block definitions here will be available for all templates.
    default.blocks do |block|
      block.headline(
        "Headline",
        size: :field,
        description: "The main statement, usually largest and boldest, " \
          "describing the main story."
      )
      block.excerpt(
        "Standfirst",
        description: "An introductory paragraph before the start of the body."
      )
      block.body(
        "Body",
        size: :large
      )
      block.boxout(
        "Boxout",
        description: "Part of the page, usually background info or facts " \
          "related to the article."
      )
   end

    # Default template (default: :autodetect, root: 'index')
    default.template :autodetect, root: "index"

    # Enables image on page (default: :enabled, linkable: false)
    default.image :enabled, linkable: false

    # Enables file uploads (default: :disabled)
    default.files :disabled

    # Enables comments (default: :disabled)
    default.comments :disabled

    # New pages are open for comments by default (default: :enabled)
    default.comments_allowed :enabled

    # Pages can have tags (default: :disabled)
    default.tags :disabled

    # Only use the blocks enabled here by default
    default.enabled_blocks [:headline, :excerpt, :body]

    # Subpages will have this template. Will fall back to default.template
    # unless specified. (default: nil)
    # default.sub_template :news_page
  end

  # Sample template configuration:

  # config.template(:news_page, :archive_page) do |t|
  #  t.blocks do |block|
  #    block.video_embed "Video embed", size: :field
  #  end
  #  t.enabled_blocks [:headline, :excerpt, :body, :boxout, :video_embed]
  #  t.sub_template :news_page
  # end
end
