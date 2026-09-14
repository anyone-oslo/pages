# frozen_string_literal: true

require "RedCloth"

module PagesCore
  # Rich text editor spike: converts Textile source to HTML the editor can
  # load. Embed codes are kept as codes (the editor turns them into nodes)
  # and RedCloth artifacts are normalised. Also reports which parts the
  # editor will keep as raw HTML blocks and which it will flatten.
  class DocumentConverter
    EMBED_CODE = /\[(?:image|attachment|file):[^\]]+\]/
    PLACEHOLDER = /EMBEDCODE(\d+)/

    # Mirrors the editor schema (DocumentEditor/extensions.ts).
    KEPT_TAGS = %w[p br a strong em s u sup h2 h3 h4 ul ol li blockquote hr
                   aside figure iframe div span notextile].freeze
    RAW_TAGS = %w[script style form table object embed].freeze
    VIDEO_HOSTS = /\A(?:www\.)?(?:youtube\.com|youtube-nocookie\.com|youtu\.be|
                      vimeo\.com|player\.vimeo\.com)\z/x

    RENAMES = { "del" => "s", "ins" => "u", "b" => "strong", "i" => "em",
                "h1" => "h2", "h5" => "h4", "h6" => "h4" }.freeze

    class << self
      def convert(text)
        new(text).convert
      end
    end

    def initialize(text)
      @text = text.to_s
    end

    def convert
      html = to_html
      doc = Nokogiri::HTML.fragment(html)
      { html:, raw: raw_blocks(doc), removed: removed_content(doc) }
    end

    # Codes stay inline (like the live embedders replace them), so
    # "[attachment:1] (pdf)" keeps its paragraph. Image codes are block
    # embeds; a paragraph holding only image codes is unwrapped.
    def to_html
      codes = []
      protected_text = @text.gsub(EMBED_CODE) do |code|
        codes << code
        "<notextile>EMBEDCODE#{codes.length - 1}</notextile>"
      end
      html = normalize(RedCloth.new(protected_text).to_html)
      html = unwrap_image_paragraphs(html, codes)
      html.gsub(PLACEHOLDER) { codes[Regexp.last_match(1).to_i] }
    end

    private

    def unwrap_image_paragraphs(html, codes)
      html.gsub(%r{<p>((?:\s*EMBEDCODE\d+\s*)+)</p>}) do |match|
        inner = Regexp.last_match(1)
        images_only = inner.scan(PLACEHOLDER).flatten
                           .all? { |i| codes[i.to_i].start_with?("[image:") }
        images_only ? inner : match
      end
    end

    def normalize(html)
      doc = Nokogiri::HTML.fragment(html)
      doc.css("p").select { |n| blank?(n) }.each(&:remove)
      doc.css("span.caps, acronym").each { |n| n.replace(n.children) }
      rename_tags(doc)
      doc.to_html
    end

    def rename_tags(doc)
      doc.css(RENAMES.keys.join(", ")).each { |n| n.name = RENAMES.fetch(n.name) }
    end

    def blank?(node)
      node.content.strip.empty? && node.element_children.empty?
    end

    # What the editor keeps as RawHtml blocks.
    def raw_blocks(doc)
      embeds = doc.css("iframe").filter_map do |n|
        host = iframe_host(n)
        "embed from #{host || 'unknown source'}" unless host&.match?(VIDEO_HOSTS)
      end
      tally(embeds + top_level(doc, RAW_TAGS.join(", ")).map(&:name))
    end

    # What the editor flattens to text.
    def removed_content(doc)
      images = doc.css("img").any? ? ["image from another website"] : []
      tags = top_level(doc, "*").map(&:name).uniq - KEPT_TAGS - RAW_TAGS - ["img"]
      tally(images + tags.map { |t| "<#{t}>" })
    end

    # Nodes not nested inside a raw block (those travel with the block).
    def top_level(doc, selector)
      doc.css(selector).reject { |n| n.ancestors.any? { |a| RAW_TAGS.include?(a.name) } }
    end

    def tally(items)
      items.tally.map { |item, n| n > 1 ? "#{n} × #{item}" : item }
    end

    def iframe_host(node)
      URI.parse(node["src"].to_s).host
    rescue URI::InvalidURIError
      nil
    end
  end
end
