require File.join(File.dirname(__FILE__), 'dependencies')

# Monkey patch Rails::Configuration to allow default gems to be added.
unless Rails::Configuration.methods.include?(:default_gem)
	class Rails::Configuration
		def self.default_gem(name, options={})
			@@default_pages_gems ||= []
			@@default_pages_gems << Rails::GemDependency.new(name, options)
		end

		alias :default_gems_before_it_got_fucked_with :default_gems
		def default_gems
			@@default_pages_gems ||= []
			default_gems_before_it_got_fucked_with + @@default_pages_gems
		end
	end
end

module PagesCore
	def self.bootstrap!
		unless const_defined?('BOOTSTRAPPED') && BOOTSTRAPPED
			class_eval "BOOTSTRAPPED = true"
			PagesCore::Dependencies.load_gems
		end
	end
end