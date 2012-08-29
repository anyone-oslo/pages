# encoding: utf-8

module PagesCore::PluginAssetsHelper

	include ActionView::Helpers::AssetTagHelper

	def stylesheet_link_tag(*sources)
		options = sources.extract_options!.stringify_keys
		if options.has_key?('plugin')
			sources = sources.map{|s| "#{options['plugin']}/#{s}"}
			options.delete('plugin')
		end
		sources << options
		super(*sources)
	end

	def javascript_include_tag(*sources)
		options = sources.extract_options!.stringify_keys
		if options.has_key?('plugin')
			sources = sources.map{|s| "#{options['plugin']}/#{s}"}
			options.delete('plugin')
		end
		sources << options
		super(*sources)
	end

	def image_path(source, options={})
		options.stringify_keys!
		source = "/assets/#{options['plugin']}/#{source}" if options['plugin']
		super(source)
	end

	def image_tag(source, options={})
		options.stringify_keys!
		if options["plugin"]
			source = "/assets/#{options['plugin']}/#{source}"
			options.delete("plugin")
		end
		super(source, options)
	end
end