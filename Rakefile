require 'rubygems'
begin
  require 'hanna/rdoctask'
rescue LoadError
  require 'rake'
  require 'rake/rdoctask'
end

begin
  require 'thinking_sphinx/tasks'
rescue LoadError
  puts "You can't load Thinking Sphinx tasks unless the thinking-sphinx gem is installed."
end
#load 'test/tasks.rake'

#desc 'Default: run unit tests.'
#task :default => :test

desc 'Generate RDoc documentation for the pages plugin.'
Rake::RDocTask.new(:doc) do |rdoc|
  rdoc.rdoc_files.include('README').
    include('lib/**/*.rb').
    include('app/**/*.rb')

  rdoc.main = "README" # page to start on
  rdoc.title = "Pages documentation"

  rdoc.rdoc_dir = 'doc' # rdoc output folder
  rdoc.options << '--inline-source' << '--charset=UTF-8'
end
