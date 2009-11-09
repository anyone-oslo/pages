module Enumerable

	# An Enumerable::Mapper object works as a proxy for a collection. Any method call 
	# on the mapper will be routed to each of the members, and the results will be
	# returned as an array.
	class Mapper
		# Create a new mapper for a collection.
		def initialize( collection )
			@collection = collection
		end
		def method_missing( meth_id, *args) #:nodoc:
			@collection.map{ |a| a.send(meth_id, *args) }
		end
	end
 
	# Returns a new mapper for the collection.
	def mapped
		Mapper.new( self )
	end
	alias_method :collected, :mapped
 
	# Group collection according to the method name or block given.
	#
	# Examples:
	#   Person.find( :all ).grouped_by( :company )
	#   Person.find( :all ).grouped_by{ |p| p.born_on.year }
	def grouped_by( method_id=nil )
		raise "No method or block given" unless method_id or block_given?
		groupings = self.map{ |i| ( block_given? ) ? yield( i ) : i.send( method_id ) }.uniq
		groupings.map{ |g| [ g, self.select{ |i| ( ( block_given? ) ? yield( i ) : i.send( method_id ) ) == g } ] }
	end	
end