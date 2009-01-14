module Enumerable
	
	# Group array according to the method name or block given
	def grouped_by( method_id=nil )
		raise "No method or block given" unless method_id or block_given?
		groupings = self.map{ |i| ( block_given? ) ? yield( i ) : i.send( method_id ) }.uniq
		groupings.map{ |g| [ g, self.select{ |i| ( ( block_given? ) ? yield( i ) : i.send( method_id ) ) == g } ] }
	end
	
end