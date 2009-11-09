module PagesCore
	module Dependencies
		class GemLoader
			class << self
				# Runs a block with a new GemLoader instance.
				def run
					yield self.new if block_given?
				end
			end
			# Adds a gem to the list to be loaded by the Rails initializer.
			def gem(name, options={})
				Rails::Configuration.default_gem name, options
			end
		end
	end
end