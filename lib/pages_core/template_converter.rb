# encoding: utf-8

class TemplateConverter
  class << self
    def convert!
      I18n.locale = :en
      localizations = convert_template("application")
      names.each do |n|
        localizations = localizations.deep_merge(convert_template(n))
      end
      localizations = localizations.deep_merge(existing_localizations)
      File.open(localization_file, "w") do |fh|
        fh.write(localizations.to_yaml)
      end
    end

    private

    def convert_template(name)
      new(name).convert!
      new(name).localizations
    end

    def existing_localizations
      return {} unless File.exist?(localization_file)
      YAML.load_file(localization_file)
    end

    def localization_file
      Rails.root.join("config", "locales", "en.yml")
    end

    def names
      Dir.glob(Rails.root.join("app/views/pages/templates/*.html.erb"))
         .map { |f| File.basename(f, ".html.erb") }
         .reject { |f| f =~ /^_/ }
    end
  end

  attr_reader :name

  def initialize(name)
    @name = name
  end

  def convert!
    if name.to_s == "application"
      generate_model(default_template_blocks, default_template_options)
    else
      generate_model(template_blocks, template_options)
    end
  end

  def localizations
    return {} if cleaned_localizations.blank?
    ns = (name.to_s == "application") ? "default" : name.to_s
    { "en" => { "templates" => {
      ns => cleaned_localizations
    } } }
  end

  private

  def block(name)
    { title: config.block(name)[:title],
      description: config.block(name)[:description],
      size: config.block(name)[:size] || :small }
  end

  def blocks(all = false)
    all_blocks = enabled_blocks.each_with_object({}) do |name, blocks|
      blocks[name] = block(name)
    end
    return all_blocks if all
    reject_blocks(
      all_blocks,
      PagesCore::Template.default_block_definitions.merge(default_blocks)
    )
  end

  def clean_localizations(hash)
    hash.reject { |_, v| v.blank? }
  end

  def cleaned_localizations
    if name.to_s == "application"
      clean_localizations(default_localizations)
    else
      clean_localizations(template_localizations)
    end
  end

  def config
    PagesCore::Deprecated::Templates::TemplateConfiguration.new(name)
  end

  def default_blocks
    config.config.get(:default, :blocks)
  end

  def default_config(key)
    config.config.get(:default, key)[:value]
  end

  def default_localizations
    default_blocks
      .reject { |k, _| predefined_blocks.include?(k) }
      .each_with_object({}) do |(k, v), hash|
        hash[k.to_s] = {
          "name" => v[:title], "description" => v[:description]
        }.reject do |n, s|
          (n == "name" && s == k.to_s.humanize) ||
            s.blank? || s == I18n.t("templates.default.#{k}.#{n}")
        end
      end
  end

  def default_subtemplate
    return nil if default_config(:template) == :autodetect
    default_config(:template)
  end

  def default_template_blocks
    reject_blocks(default_blocks, PagesCore::Template.default_block_definitions)
      .map { |n, o| "#{n}:#{o[:size] || 'small'}" }
  end

  def default_template_options
    { enabled_blocks: default_config(:enabled_blocks).join(","),
      comments: default_config(:comments),
      comments_allowed: default_config(:comments_allowed),
      images: default_config(:images) || default_config(:image),
      tags: default_config(:tags),
      subtemplate: default_subtemplate,
      parent: "PagesCore::Template" }
  end

  def enabled_blocks
    config.enabled_blocks - [:name]
  end

  def generate_model(blocks, options)
    Rails::Generators.invoke(
      "pages_core:template",
      [name, blocks, *generator_args(options.merge(view: false))]
    )
  end

  def generator_args(hash)
    hash.map { |name, value| "--#{name.to_s.dasherize}=#{value}" }
  end

  def images?
    config.value(:images) || config.value(:image)
  end

  def predefined_blocks
    [:meta_title, :meta_description, :open_graph_title, :open_graph_description]
  end

  def reject_blocks(blocks, defs)
    blocks
      .reject { |k, _| predefined_blocks.include?(k) }
      .reject { |k, v| defs.key?(k) && defs[k][:size] == (v[:size] ||= :small) }
  end

  def template_blocks
    (blocks.map { |n, o| "#{n}:#{o[:size]}" } - default_template_blocks)
  end

  def template_localizations
    blocks(true)
      .reject { |k, _| predefined_blocks.include?(k) }
      .each_with_object({}) do |(k, v), hash|
        hash[k.to_s] = {
          "name" => v[:title], "description" => v[:description]
        }.reject do |n, s|
          s.blank? ||
            (n == "name" && s == k.to_s.humanize) ||
            (default_localizations[k.to_s] &&
            default_localizations[k.to_s][n] == s) ||
            s == I18n.t("templates.#{name}.#{k}.#{n}") ||
            s == I18n.t("templates.default.#{k}.#{n}")
        end
      end
  end

  def template_options
    {
      enabled_blocks: enabled_blocks.join(","),
      comments: config.value(:comments),
      comments_allowed: config.value(:comments_allowed),
      images: images?,
      tags: config.value(:tags),
      subtemplate: config.value(:sub_template)
    }.reject { |k, v| default_template_options[k] == v }
  end
end
