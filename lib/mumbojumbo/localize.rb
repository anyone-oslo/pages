# encoding: utf-8

# Derived from the Gibberish plugin, which is copyright (c) 2007 Chris Wanstrath.
# http://plugins.require.errtheblog.com/browser/gibberish

module MumboJumbo
	module Localize
		@@default_language = :eng
		mattr_reader :default_language

		@@reserved_keys = [ :limit ]
		mattr_reader :reserved_keys

		@@translators = []
		mattr_accessor :translators

		def add_reserved_key(*key)
			(@@reserved_keys += key.flatten).uniq!
		end
		alias :add_reserved_keys :add_reserved_key

		@@languages = {}
		def languages
			@@languages.keys
		end

		@@current_language = nil
		def current_language
			@@current_language || default_language
		end

		def current_language=(language)
			load_languages! if Rails.env.development?
			language = language.to_sym if language.respond_to? :to_sym
			@@current_language = language
		end

		def use_language(language)
			start_language = current_language
			self.current_language = language
			result = yield
			self.current_language = start_language
			result
		end

		def without_translators
			start_translators = @@translators
			@@translators = []
			result = yield
			@@translators = start_translators
			result
		end

		def default_language?
			current_language == default_language
		end

		def translations
			@@languages[current_language] || {}
		end

		def get_translation( key )
			return if reserved_keys.include? key
			translations[key.to_sym] || ""
		end

		def translate(string, key, *args)
			return if reserved_keys.include? key
			target = translations[key] || string
			if translators_have_key?( key, target )
				target = get_target_from_translators( key, target )
			end
			interpolate_string(target.dup, *args.dup)
		end

		def load_languages!
			language_files.each do |file|
				key = File.basename(file, '.*').to_sym
				@@languages[key] ||= {}
				@@languages[key].merge! YAML.load_file(file).symbolize_keys
			end
			languages
		end

		@@language_paths = [Rails.root.to_s]
		mattr_reader :language_paths
		def language_paths
			@@language_paths ||= []
		end

		def add_language_path( path )
			@@language_paths.delete(Rails.root.to_s)
			@@language_paths = [ @@language_paths, path, Rails.root.to_s].flatten
		end

		def reset_language_paths!
			@@language_paths = [Rails.root.to_s]
		end

		private
		def interpolate_string(string, *args)
			if args.last.is_a? Hash
				interpolate_with_hash(string, args.last)
			else
				interpolate_with_strings(string, args)
			end
		end

		def interpolate_with_hash(string, hash)
			hash.inject(string) do |target, (search, replace)|
				target.sub("{#{search}}", replace)
			end
		end

		def interpolate_with_strings(string, strings)
			string.gsub(/\{\w+\}/) { strings.shift }
		end

		def language_files
			@@language_paths.map {|path| Dir[File.join(path, 'lang', '*.{yml,yaml}')]}.flatten
		end

		def translators_have_key?( key, string )
			@@translators.inject( false ){ |has_key,translator| has_key ||= translator.has_key?( key, current_language, string ) }
		end

		def get_target_from_translators( key, string )
			return false unless translators_have_key?( key, string )
			@@translators.select{ |t| t.has_key? key, current_language, string }.first.get_target( key, current_language, string )
		end

	end
end
