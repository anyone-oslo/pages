module PagesCore
  # = Template
  #
  # A Template object is the bridge between a Page and the view.
  #
  # == Configuration
  #
  # Images, files, comments and tags can be toggled on or off per
  # template. They're all disabled by default.
  #
  #   class ArticleTemplate < ApplicationTemplate
  #     comments true
  #     files false
  #     images true
  #     tags true
  #   end
  #
  # The template name can also be configured.
  #
  #   class HomeTemplate < ApplicationTemplate
  #     name "Home page"
  #   end
  #
  # == Blocks
  #
  # A block is a piece of content, and a template can have has many
  # blocks as desired. By default, the <tt>:name</tt>,
  # <tt>:headline</tt>, <tt>:excerpt</tt> and <tt>:body</ttt> blocks
  # are defined and enabled. The <tt>:name</tt> block is special and
  # will always be present.
  #
  #   class ArticleTemplate < ApplicationTemplate
  #     block :video_embed, size: :small
  #     enabled_blocks :headline, :body, :video_embed
  #   end
  #
  # Valid size options for a block definition are <tt>:field</tt>,
  # <tt>:small</tt> and <tt>:large</tt>. <tt>:field</tt> will be
  # rendered as a text field, and the other two as text areas.
  #
  # Blocks must be enabled by setting <tt>enabled_blocks</tt>. This
  # also determines the ordering.
  #
  # The name and description for each block can be customized using
  # the Rails I18n system. The lookup keys are
  # <tt>templates.<template name>.<block_name>.name</tt> and
  # <tt>templates.<template name>.<block_name>.description</tt>.
  #
  # == Defaults and inheritance
  #
  # All properties except for <tt>filename</tt> are inherited when
  # subclassing. Typically this will be used to set a default configuration
  # in <tt>ApplicationTemplate</tt>.
  #
  #   class ApplicationTemplate < PagesCore::Template
  #     block :video_embed, size: :small
  #   end
  #
  #   class ArticleTemplate < ApplicationTemplate
  #     enabled_blocks :headline, :body, :video_embed
  #   end
  class Template
    class NotFoundError < StandardError; end

    include PagesCore::TemplateBlocks

    class << self
      delegate :id, to: :new

      def inherited(template)
        PagesCore::Template.templates << template
      end

      def configuration
        @configuration ||= {}
      end

      def default_configuration
        { enabled_blocks:   [:headline, :excerpt, :body],
          filename:         nil,
          name:             nil,
          render:           proc {},
          subtemplate:      nil }.merge(default_options)
      end

      def find(id)
        templates.find { |t| t.new.id == id.to_sym } ||
          raise(NotFoundError, "Cannot find the \"#{id}\" template")
      end

      def get(key)
        return configuration[key] if configuration.key?(key)
        return superclass.get(key) if superclass.respond_to?(:get)
        default_configuration[key]
      end

      def load_all!
        template_roots.each do |root|
          matcher = %r{\A#{Regexp.escape(root.to_s)}/(.*)\.rb\Z}
          Dir.glob("#{root}/**/*.rb").sort.each do |file|
            require_dependency file.sub(matcher, '\1')
          end
        end
      end

      def name(new_name)
        set(:name, new_name)
      end

      def selectable
        (templates - [ApplicationTemplate]).sort_by(&:id)
      end

      def render(&block)
        set(:render, block)
      end

      def set(key, value, *extra)
        return configuration[key] = value unless extra.any?
        configuration[key] = [value] + extra
      end

      def templates
        load_all! unless Rails.application.config.eager_load
        @templates ||= Set.new
      end

      private

      def default_options
        { comments:         false,
          comments_allowed: true,
          files:            false,
          images:           false,
          tags:             false }
      end

      def template_roots
        [
          PagesCore.plugin_root.join("app", "templates"),
          Rails.root.join("app", "templates")
        ].select { |p| Dir.exist?(p) }
      end

      def method_missing(name, *args)
        if default_configuration.keys.include?(name)
          return get(name) if args.empty?
          set(name, *args)
        else
          super
        end
      end
    end

    def filename
      self.class.get(:filename) || id.to_s
    end

    def id
      self.class.to_s.gsub(/Template$/, "").underscore.to_sym
    end

    def name
      return self.class.get(:name) if self.class.configuration.key?(:name)
      id.to_s.humanize
    end

    def path
      "pages/templates/#{filename}"
    end

    def method_missing(name, *args)
      key = name.to_s.gsub(/\?$/, "").to_sym
      if key?(key)
        return self.class.get(key) ? true : false if name.to_s =~ /\?$/
        return self.class.get(key)
      end
      super
    end

    private

    def key?(key)
      self.class.default_configuration.key?(key)
    end
  end
end
