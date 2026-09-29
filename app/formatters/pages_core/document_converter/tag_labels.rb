# frozen_string_literal: true

module PagesCore
  class DocumentConverter
    # Plain words for the conversion report, so clients never see tag names.
    module TagLabels
      LABELS = {
        "h2" => "headings", "h3" => "headings", "h4" => "headings",
        "ul" => "lists", "ol" => "lists", "li" => "lists",
        "blockquote" => "quotes", "table" => "tables",
        "hr" => "horizontal rules", "aside" => "fact boxes",
        "figure" => "figures", "script" => "scripts", "style" => "styles",
        "form" => "forms", "iframe" => "embeds", "object" => "embeds",
        "embed" => "embeds", "u" => "underline or strikethrough",
        "s" => "underline or strikethrough", "center" => "centred text",
        "font" => "font styling"
      }.freeze

      def self.for(tag)
        LABELS.fetch(tag) { "other formatting (<#{tag}>)" }
      end
    end
  end
end
