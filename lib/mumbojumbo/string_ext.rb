# Derived from the Gibberish plugin, which is copyright (c) 2007 Chris Wanstrath.
# http://plugins.require.errtheblog.com/browser/gibberish

module MumboJumbo
	module StringExt
		def brackets_with_translation(*args)
			args = [underscore.tr(' ', '_').to_sym] if args.empty?
			return brackets_without_translation(*args) unless args.first.is_a? Symbol
			MumboJumbo.translate(self, args.shift, *args)
		end

		def self.included(base)
			base.class_eval do
				alias :brackets :[]
				alias_method_chain :brackets, :translation
				alias :[] :brackets
			end
		end
	end
end
