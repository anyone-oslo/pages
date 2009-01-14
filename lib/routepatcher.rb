require 'find'
require 'tempfile'

# Patches namespaced routes for Rails 2.0.
#
# Usage:
#
# patcher = RoutePatcher.new( "/path/to/rails_app" )
# patcher.register_prefix( [ 'admin', 'namespace2' ] )
# patcher.patch!

class RoutePatcher
	attr_accessor :path
	attr_accessor :prefixes

	def new_route( string )
		output = ""
		if string =~ /^hash_for_/
			output += "hash_for_"
			string = string.gsub( /^hash_for_/, '' )
		end
		prefix   = string.match( Regexp.new( "(" + @prefixes.join("|") + ")" ) )[1]
		resource = string.match( Regexp.new( "(" + self.resources.join("|") + ")" ) )[1]
		action   = string.match( Regexp.new( "#{prefix}_(.*)#{resource}" ) )[1] rescue nil
		action   = nil if action && action.empty?
		method   = string.match( /_(path|url)$/ )[1]
		output += [ action, prefix, resource, method ].compact.join( "_" ).gsub("__","_")
		output
	end

	def parse_routes( string )
		@helpers = []
		string.split("\n").each do |l|
			if( m = l.match( /([\w]+_[\w_]+)/ ) )
				@helpers << m[1] if l.match( Regexp.new( "(" + @prefixes.join("|") + ")_" ) )
			end
		end
	end

	def resources
		unless @resources
			@resources = []
			@helpers.each do |h|
				resource = h.match( Regexp.new( "(" + @prefixes.join("|") + ")_(.*)$" ) )
				if resource
					@resources << resource[2] unless @resources.include?( resource[2] )
				end
			end
		end
		@resources
	end


	def initialize( path )
		@path = path
		@prefixes = []
	end

	def files
		unless @files
			@files = []
			Find.find( @path ) do |file|
				if File.file?( file ) && !file.match( /\.svn/ ) && !file.match( /\.(gif|jpg|log)$/ )
					@files << file
				end
			end
		end
		@files
	end

	def files_to_patch
		@files_to_patch ||= self.files.select do |f|
			file_contents = File.read( f )
			if file_contents.match( Regexp.new( "(" + @prefixes.join("|") + ")_" ) )
				true
			else
				false
			end
		end
	end

	def register_prefix( prefix=[] )
		prefix = [prefix] unless prefix.kind_of?( Array )
		prefix.each do |p|
			@prefixes << p unless @prefixes.include?( p )
		end
	end

	def find_tokens( string )
		tokens = []
		string.gsub( /[\w_]+/ ) do |m|
			if m.match( Regexp.new( "(" + @prefixes.join("|") + ").*_(path|url)" ) ) && m.match( Regexp.new( "(" + self.resources.join("|") + ")" ) )
				tokens << m
			end
			m
		end
		tokens.uniq
	end

	def patch!
		self.parse_routes( `cd #{@path} && rake routes` )
		files_to_patch.each do |f|
			new_file_content = File.read( f )
			replaced = false
			unless ( tokens = self.find_tokens( new_file_content ) ).empty?
				replaced = true
				tokens.each do |token|
					new_file_content = new_file_content.gsub( token, self.new_route( token ) )
				end
			end
		
			if replaced
				diff_output = ""
				Tempfile.open( 'route_patcher' ) do |temp|
					temp.write( new_file_content )
					temp.flush
					diff_output = `diff -u #{f} #{temp.path}`
				end
				unless diff_output.strip.empty?
					puts "".rjust(160, "-")
					puts diff_output
					print "\nDoes this look OK? (Y/n) "
					do_patch = ( STDIN.gets.chomp.downcase == 'n' ) ? false : true
					if do_patch
						puts "OK, writing file\n\n"
						File.open( f, "w" ) do |fh|
							fh.write( new_file_content )
						end
					else
						puts "NOT OK, skipping...\n\n"
					end
				end
			end
		end
	end

end

