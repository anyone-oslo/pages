class Partial < ActiveRecord::Base

	validates_presence_of :name
	validates_uniqueness_of :name
	
	acts_as_textable [ "body" ], :allow_any => false
	
	class << self
		attr_accessor :allowed_names
		def allowed_names
			@allowed_names = Pages.config :partials
			@allowed_names ||= []
		end
		def names
			[ allowed_names, Partial.find( :all ).map{ |f| f.name } ].flatten.map{ |n| n.to_s }.uniq.sort
		end
		def has_partials?
			( self.names.length > 0 ) ? true : false
		end
	end

	def has_language?( language )
		self.languages.include?( language )
	end
	
	def human_name
		self.name.humanize
	end
	
	def is_overridden?
		self.body?
	end
	
	def default_body
		string = ""
		MumboJumbo.use_language( self.working_language ) do
			string = MumboJumbo.get_translation( self.name )
		end
		string
	end
	
	def to_s
		( self.is_overridden? ) ? self.body.to_s : self.default_body
	end
	
end