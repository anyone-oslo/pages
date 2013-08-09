# encoding: utf-8

# Configuration file for Pages CMS
# Be sure to restart your web server when you modify this file.

# Default language
Language.default = Language.code_for_name("<%= @default_language %>")

# Site configuration
PagesCore.configure do |config|
  # Site name and default mail sender
  config.site_name      "<%= @site_name %>"
  config.default_sender "<%= @mail_sender %>"

  # Uncomment the options below to toggle them
  #config.localizations :enabled       # Enable localizations
  #config.recaptcha :enabled           # Enable ReCAPTCHA
  #config.page_cache :disabled         # Disable page cache (not recommended)
  #config.domain_based_cache :enabled	 # Enable domain based page cache (for multiple domains)
  #config.newsletter.template :enabled # Enable template based newsletters
  #config.newsletter.image :enabled    # Enable image in newsletters
  #config.rss_fulltext :enabled        # Enable fulltext in RSS feeds

  # Will try to load images from production if they are missing in development
  #config.image_fallback_url "http://<%= @site_domain %>/"

  # Uncomment to send notifications on comments
  #config :comment_notifications,  [:author, 'your@email.com']

  # Automatically close comments after 60 days
  #config.close_comments_after 60.days

  # Enable comment honeypot.
  # Add <%= comment_honeypot_field %> to your form and .comment_email { display: none; } to your CSS.
  #config.comment_honeypot :enabled
end

# Templates configuration
PagesCore::Templates.configure do |config|

  # Default configuration for all templates
  config.default do |default|
    ### The block definitions here will be available for all templates.
    # default.blocks do |block|
    # 	block.headline    "Headline",   :description => 'The main statement, usually largest and boldest, describing the main story.', :size => :field
    # 	block.excerpt     "Standfirst", :description => 'An introductory paragraph before the start of the body.'
    # 	block.body        "Body",       :size => :large
    #  	block.boxout      "Boxout",     :description => 'Part of the page, usually background info or facts related to the article.'
    # end

    ### These are the default options for all templates.
    # default.template         :autodetect, :root => 'index' # Autodetect template, root template is 'index'.
    # default.image            :enabled, :linkable => false  # Image is enabled by default, but not linkable
    # default.files            :disabled                     # Files are disabled by default
    # default.images           :disabled                     # Additional images are disabled by default
    # default.text_filter      :textile                      # Use textile as default text filter
    # default.comments         :enabled                      # Enables/disables the comments functionality
    # default.comments_allowed :enabled                      # Default comments_allowed value for new pages
    # default.enabled_blocks [:headline, :excerpt, :body]    # Only use the blocks enabled here by default
  end

  # Sample template configurations:

  ### News container template
  # config.template(:news) do |t|
  # 	t.enabled_blocks []         # Disable everything but the page title
  # 	t.sub_template   :news_page # Use news_page template for children
  # 	t.image          :disabled  # Disable image
  # 	t.comments       :disabled  # Disable comments
  # end

  ### Configure multiple templates at once
  # config.template(:news_page, :news_page_with_video) do |t|
  # 	t.blocks do |block|
  # 		# Rename the excerpt block for this template and make it large.
  # 		block.excerpt     "Intro", :size => :large
  # 		# Make the body required.
  # 		block.body        "Body", :required => true
  #       # Define a video embed block. Note: This is only the definition,
  #       # enabled_blocks controls which blocks are used.
  # 		block.video_embed "Video embed", :description => 'Embed a video here'
  # 	end
  # 	t.enabled_blocks [:headline, :excerpt, :body, :boxout]
  # 	t.image          :enabled, :linkable => true    # Make image linkable
  # 	t.comments       :enabled                       # Enable comments
  # end

  ### Add a video embed field to the previously defined news_page_with_video template
  # config.template(:news_page_with_image) do |t|
  # 	t.enabled_blocks [:headline, :excerpt, :body, :video_embed]
  # end

end

# Configure the cache sweeper, add any custom paths and models
# PagesCore::CacheSweeper.config do |sweeper_config|
# 	sweeper_config.observe  += [:store, :store_test, :ad]
# 	sweeper_config.patterns += [/^\/arkiv(.*)$/, /^\/tests(.*)$/]
# end
