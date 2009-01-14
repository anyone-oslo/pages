class Pages::StringTranslator
	
	@@cached_partials = {}
	
	def self.has_key?( key, language, string )
		key = key.to_s
		partial = self.get_target( key, language, string )
		if partial
			true
		else
			# Removed for caching
			#partial = Partial.create( :name => key )
			#partial.working_language = language
			#partial.body = string
			#partial.save
			false
		end
	end
	
	def self.get_target( key, language, string )
		key = key.to_s
		if @@cached_partials.has_key? key
			partial = @@cached_partials[key]
		else
			partial = Partial.find_by_name( key )
			@@cached_partials[key] = partial
		end
		if partial.kind_of?( Partial ) && partial.has_language?( language ) && partial.body?
			partial.body.translate( language ).to_s
		else
			false
		end
	end
	
end