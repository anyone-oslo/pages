require 'autotest'
require 'autotest/rails'

class Autotest::EnginesRails < Autotest::Rails

	def initialize # :nodoc:
		super
	    @test_mappings = @test_mappings.merge( {
	      %r%^vendor/plugins/(.*)/test/fixtures/(.*)s.yml% => proc { |_, m|
	        ["vendor/plugins/#{m[1]}/test/unit/#{m[2]}_test.rb",
	         "vendor/plugins/#{m[1]}/test/controllers/#{m[1]}_controller_test.rb",
	         "vendor/plugins/#{m[1]}/test/views/#{m[2]}_view_test.rb",
	         "vendor/plugins/#{m[1]}/test/functional/#{m[2]}_controller_test.rb"]
	      },
	      %r%^vendor/plugins/.*/test/(unit|integration|controllers|views|functional)/.*rb$% => proc { |filename, _|
	        filename
	      },
	      %r%^vendor/plugins/(.*)/app/models/(.*)\.rb$% => proc { |_, m|
	        ["vendor/plugins/#{m[1]}/test/unit/#{m[2]}_test.rb"]
	      },
	      %r%^vendor/plugins/(.*)/app/helpers/application_helper.rb% => proc { |_, m|
	        files_matching %r%^vendor/plugins/.*/test/(views|functional)/.*_test\.rb$%
	      },
	      %r%^vendor/plugins/(.*)/app/helpers/(.*)_helper.rb% => proc { |_, m|
	        if m[2] == "application" then
	          files_matching %r%^vendor/plugins/#{m[1]}/test/(views|functional)/.*_test\.rb$%
	        else
	          ["vendor/plugins/#{m[1]}/test/views/#{m[2]}_view_test.rb",
	           "vendor/plugins/#{m[1]}/test/functional/#{m[2]}_controller_test.rb"]
	        end
	      },
	      %r%^vendor/plugins/(.*)/app/views/(.*)/% => proc { |_, m|
	        ["vendor/plugins/#{m[1]}/test/views/#{m[2]}_view_test.rb",
	         "vendor/plugins/#{m[1]}/test/functional/#{m[2]}_controller_test.rb"]
	      },
	      %r%^vendor/plugins/(.*)/app/controllers/(.*)\.rb$% => proc { |_, m|
	        if m[2] == "application" then
	          files_matching %r%^vendor/plugins/.*/test/(controllers|views|functional)/.*_test\.rb$%
	        else
	          ["vendor/plugins/#{m[1]}/test/controllers/#{m[2]}_test.rb",
	           "vendor/plugins/#{m[1]}/test/functional/#{m[2]}_test.rb"]
	        end
	      },
	      %r%^vendor/plugins/(.*)/app/views/layouts/% => proc { |_, m|
	        "vendor/plugins/#{m[1]}/test/views/layouts_view_test.rb"
	      },
	      %r%^vendor/plugins/(.*)/routes.rb$% => proc { |_, m| # FIX:
	        files_matching %r%^vendor/plugins/.*/test/(controllers|views|functional)/.*_test\.rb$%
	      }
		} )
	end


	# Convert the pathname s to the name of class.
	def path_to_classname(s)
		sep = File::SEPARATOR
		s = s.sub(/^vendor\/plugins\/[\w\d_-]+\//, '')
		f = s.sub(/^test#{sep}((unit|functional|integration|views|controllers|helpers)#{sep})?/, '').sub(/\.rb$/, '').split(sep)
		f = f.map { |path| path.split(/_/).map { |seg| seg.capitalize }.join }
		f = f.map { |path| path =~ /Test$/ ? path : "#{path}Test"  }
		f.join('::')
	end

	def consolidate_failures(failed)
		filters = Hash.new { |h,k| h[k] = [] }
		class_map = Hash[*@files.keys.grep(/test/).map { |f| [path_to_classname(f), f] }.flatten]
		
		failed.each do |method, klass|
			if class_map.has_key? klass then
				filters[class_map[klass]] << method
			else
				@output.puts "-- Unable to map class #{klass} to a file"
			end
		end

		return filters
	end
end
