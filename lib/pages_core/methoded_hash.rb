module PagesCore
	class MethodedHash < Hash
		def method_missing(key,args=nil)
			key = key.to_s
			if key =~ /=$/
				key = key.gsub(/=$/, '')
				self[key.to_sym] = args
			else
				(self.has_key?(key.to_sym)) ? self[key.to_sym] : nil
			end
		end
	end
end