# frozen_string_literal: true

module Admin
  class TemplateConfigurationResource
    include Alba::Resource

    attributes :name, :template_name

    attribute :blocks do
      object.enabled_blocks.map do |block_name|
        block(block_name)
      end
    end

    attribute :metadata_blocks do
      object.metadata_blocks.map do |block_name|
        block(block_name)
      end
    end

    attribute :images do
      object.value(:images) || object.value(:image)
    end

    %i[dates tags files].each do |attr|
      attribute attr do
        object.value(attr)
      end
    end

    private

    def block(block_name)
      reify_options(object.block(block_name).merge(name: block_name))
    end

    def reify_options(block)
      return block unless block.key?(:options)

      opts = block[:options]
      opts = opts.call if opts.is_a?(Proc)
      opts = opts.map { |v| [v, v] } unless opts.present? && opts.first.is_a?(Array)
      opts = ([["", nil]] + opts).uniq

      block.merge(options: opts)
    end
  end
end
