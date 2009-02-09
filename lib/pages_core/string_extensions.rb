require 'iconv'
module PagesCore
	module StringExtensions

		# Convert any string to ASCII
		def ascii
			@@ascii_converter ||= Iconv.new("ASCII//TRANSLIT", "UTF-8")
			old_kcode = $KCODE # Backup $KCODE
			string    = self

			# Do tuned translation first.
			[
				['Ö','O'],  ['ö','o'],
				['Æ','AE'], ['æ','ae'],
				['Ø','OE'], ['ø','oe'],
				['Å','AA'], ['å','aa'],
			].each{ |s,r| string.gsub!(s,r) }
			
			# Translate each char with iconv. This is done on char level 
			# in order to trap errors. 
			chars = (string.respond_to?(:mb_chars)) ? string.mb_chars : string.chars
			string = chars.map do |char|
				@@ascii_converter.iconv( string ) rescue '?'
			end.join

			$KCODE = old_kcode # Restore $KCODE
			return string
		end
		
		# Truncate string to max_length, retaining words. If the first word is shorter than max_length, 
        # it will be shortened. An optional end_string can be supplied, which will be appended to the 
        # string if it has been truncated.
    	def truncate(max_length, end_string='')
    	    words = self.split(' ')
    	    new_words = [words.shift]
    	    while words.length > 0 && (new_words.join(' ').length + words.first.length) < max_length
    	        new_words << words.shift
            end
            new_string = new_words.join(' ')
            new_string = new_string[0...max_length] if new_string.length > max_length
            new_string += end_string unless new_string == self
            return new_string
        end
        
	end
end

String.send( :include, PagesCore::StringExtensions )
