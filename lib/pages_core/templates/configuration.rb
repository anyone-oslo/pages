require File.join(File.dirname(__FILE__), '../hash_extensions')
require File.join(File.dirname(__FILE__), '../configuration')

module PagesCore
	module Templates
		class Configuration < PagesCore::Configuration::Handler
			VALID_TEMPLATE_OPTIONS = :template, :image, :images, :files, :text_filter, :blocks, :enabled_blocks, :sub_template, :comments
			
			handle :default do |instance, name, *args|
				if name == :blocks
					blocks_proxy = instance.blocks
					args.first.call(blocks_proxy) if args.first.kind_of?(Proc)
					blocks_proxy
				else
					instance.configure_template(:_defaults, name, *args)
				end
			end
			
			def configure_block(template_name, block_name, title=false, options={})
				block_name = block_name.to_sym
				title ||= block_name.to_s.humanize
				options[:title] = title
				if template_name == :_defaults
					set([:default, :blocks, block_name], options)
				else
					set([:templates, template_name, :blocks, block_name], options)
				end
			end

			def configure_template(template_name, setting, value, options={})
				template_name = template_name.to_sym
				setting = setting.to_sym
				if VALID_TEMPLATE_OPTIONS.include?(setting)
					value = true  if value == :enabled
					value = false if value == :disabled
					template_config = {
						setting => {
							:value   => value,
							:options => options
						}
					}
					if template_name == :_defaults
						set([:default], template_config)
					else
						set([:templates, template_name], template_config)
					end
				else
					raise "Invalid template configuration value: #{setting.inspect}"
				end
			end

			def blocks(template_name = :_defaults, &block)
				proxy(block) { |name, *args| self.configure_block(template_name, name, *args)}
			end
			
			def templates(*args, &block)
				template_names = args.flatten.map{|a| a.to_sym}
				proxy(block) do |name, *args|
					if name == :blocks
						proxy(args.first.kind_of?(Proc) ? args.first : nil) do |n2, *a2|
							template_names.each do |template_name| 
								self.configure_block(template_name, n2, *a2)
							end
						end
					else
						template_names.each do |template_name|
							self.configure_template(template_name, name, *args)
						end
					end
				end
			end
			alias :template :templates
		end
	end
end