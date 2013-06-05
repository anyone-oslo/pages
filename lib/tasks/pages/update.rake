# encoding: utf-8

require 'find'
require 'open-uri'

namespace :pages do
  namespace :update do

    desc "Fix inheritance"
    task :fix_inheritance do
      def find_files(file_expression, options={})
        paths = []
        Find.find(".") do |path|
          gsubbed_path = path.gsub(/^\.?\/?/,'')
          Find.prune if options[:except] && gsubbed_path =~ options[:except]
          if gsubbed_path =~ file_expression && !(path =~ /\.git/)
            paths << path unless File.directory?(path)
          end
        end
        paths
      end

      # Update controllers
      find_files(%r%^app/controllers/.*\.rb%).each do |controller|
        plugin_controller = File.join('vendor/plugins/pages', controller)
        if File.exists?(plugin_controller)
          class_definition = File.read(plugin_controller).split(/\n/).select{|l| l =~ /class/}.first
          file_content = File.read(controller)
          patched_file_content = file_content.gsub(/class [\w:]+Controller( < [\w:]+)/, class_definition)
          unless patched_file_content == file_content
            puts "Patching file #{controller}.."
            File.open(controller, 'w') {|fh| fh.write(patched_file_content)}
          end
        end
      end

      # Update helpers
      find_files(%r%^app/helpers/.*\.rb%).each do |helper|
        plugin_helper = File.join('vendor/plugins/pages', helper)
        if File.exists?(plugin_helper)
          helper_name = helper.gsub(/.*\/app\/helpers\//, '').gsub(/\.rb$/, '').camelize
          includes = File.readlines(plugin_helper).select{|l| l =~ /^\s*include /}
          includes.map!{|i| i.match(/\s*include\s+([\w\d:]+)/)[1]}
          file_content = File.read(helper)
          patched_file_content = file_content.dup
          includes.reverse.each do |include_module|
            unless file_content =~ Regexp.new('include\s+' + include_module)
              patched_file_content.gsub!(Regexp.new('module\s+' + helper_name)) do
                "module #{helper_name}\n\tinclude #{include_module}"
              end
            end
          end

          unless patched_file_content == file_content
            puts "Patching file #{helper}.."
            File.open(helper, 'w') {|fh| fh.write(patched_file_content)}
          end
        end
      end

    end

    desc "Patch files"
    task :files do
      def find_files(file_expression, options={})
        paths = []
        Find.find(".") do |path|
          gsubbed_path = path.gsub(/^\.?\/?/,'')
          Find.prune if options[:except] && gsubbed_path =~ options[:except]
          if gsubbed_path =~ file_expression && !(path =~ /\.git/)
            paths << path unless File.directory?(path)
          end
        end
        paths
      end
      def patch_files(file_expression, expression, sub, options={})
        updated_files = []
        find_files(file_expression, options).each do |path|
          file_content = File.read(path)
          skip_file = (options.has_key?(:unless_matches) && file_content =~ options[:unless_matches]) ? true : false
          patched_file_content = file_content.gsub(expression, sub)
          unless file_content == patched_file_content || skip_file
            puts "Patching file #{path}.."
            updated_files << path
            File.open(path, 'w') {|fh| fh.write(patched_file_content)}
          end
        end
        if updated_files.length > 0
          yield updated_files if block_given?
        end
      end

      # Update the Rakefile
      patch_files(
        %r%^Rakefile% ,
        /^require 'rake\/rdoctask'/,
        "require 'rdoc/task'"
      ) do
        puts "* Updated RDoc require in Rakefile"
      end

      # Add the root route
      patch_files(
        %r%^config/routes.rb% ,
        /^end/,
        "\tmap.root :controller => 'pages', :action => 'index'\nend",
        :unless_matches => /^\s+map.root/
      ) do
        puts "* Added root route"
      end

      # Passenger/RVM
      if !File.exists?('config/setup_load_paths.rb')
        puts "* setup_load_paths.rb not found, installing default..."
        slp_template = File.join(File.dirname(__FILE__), '../../../template/config/setup_load_paths.rb')
        `cp #{slp_template} config/setup_load_paths.rb`
      end

      # Rack config
      if !File.exists?('config.ru') || !(File.read('config.ru') =~ /sprockets/)
        puts "* Rack config not found or wrong, installing default..."
        rack_template = File.join(File.dirname(__FILE__), '../../../template/config.ru')
        `cp #{rack_template} config.ru`
      end

      # Sprockets initializer
      if !File.exists?('config/initializers/sprockets.rb')
        puts "* Sprockets initializer not found, installing default..."
        sprockets_template = File.join(File.dirname(__FILE__), '../../../template/config/initializers/sprockets.rb')
        `cp #{sprockets_template} config/initializers/sprockets.rb`
      end

      # Bundler
      if !File.exists?('Gemfile')
        puts "* Gemfile not found, installing default..."
        gemfile_template = File.join(File.dirname(__FILE__), '../../../template/Gemfile')
        `cp #{gemfile_template} Gemfile`
      end
      patch_files(
        %r%^config/boot\.rb%,
        /^[\s]*Rails\.boot!/,
        "class Rails::Boot\n  def run\n    load_initializer\n    Rails::Initializer.class_eval do\n      def load_gems\n        @bundler_loaded ||= Bundler.require :default, Rails.env\n      end\n    end\n    Rails::Initializer.run(:set_load_path)\n  end\nend\n\nRails.boot!",
        :unless_matches => /Bundler.require/
      ) do |files|
        puts "* boot.rb patched for Bundler"
      end
      if !File.exists?('config/preinitializer.rb')
        preinit_template = File.join(File.dirname(__FILE__), '../../../template/config/preinitializer.rb')
        `cp #{preinit_template} config/preinitializer.rb`
        abort "\n* Updated for Bundler support, please run pages:update again."
      end

      if !File.exists?("app/assets")
        puts "* Assets folder not found, creating..."
        FileUtils.mkdir_p Rails.root.join('app', 'assets', 'javascripts')
        FileUtils.mkdir_p Rails.root.join('app', 'assets', 'stylesheets')
        `touch app/assets/javascripts/.gitignore`
        `touch app/assets/stylesheets/.gitignore`
        `git add app/assets/javascripts/.gitignore`
        `git add app/assets/stylesheets/.gitignore`
        `git mv public/javascripts/* app/assets/javascripts`
        `git mv public/stylesheets/* app/assets/stylesheets`
      end

      ['stylesheets', 'javascripts', 'plugin_assets'].each do |dir|
        if File.exists?("public/#{dir}")
          puts "* public/#{dir} found, removing..."
          `git rm -r public/#{dir}`
          `rm -rf public/#{dir}`
        end
      end

    end

    desc "Update gems"
    task :gems do
      puts "Updating Bundler..."
      `bundle install`
    end

    desc "Update migrations"
    task :migrations => :environment do
      new_migrations = PagesCore::Plugin.mirror_migrations!
      if new_migrations.any?
        puts "\n#{new_migrations.length} new migrations added, now run rake db:migrate"
      end
    end

    desc "Update submodules"
    task :remove_old_submodules do
      puts "Removing old submodules..."
      %w{acts_as_list acts_as_tree delayed_job dynamic_image engines recaptcha thinking-sphinx}.each do |plugin|
        if File.exists?("vendor/plugins/#{plugin}")
          `rm -rf vendor/plugins/#{plugin}`
          `git rm vendor/plugins/#{plugin}`

          # Remove from .gitmodules
          if File.exists?('.gitmodules')
            gitmodules = File.readlines('.gitmodules').reject{|l| l =~ Regexp.new(plugin)}.join
            File.open('.gitmodules', 'w'){|fh| fh.write gitmodules}
          end

          # Remove from .git/config
          if File.exists?('.git/config')
            git_config = File.readlines('.git/config').reject{|l| l =~ Regexp.new(plugin)}.join
            File.open('.git/config', 'w'){|fh| fh.write git_config}
          end
        end
      end
    end

    desc "Updates submodules"
    task :submodules do
      puts "Updating submodules..."
      #`git submodule update --init`
      #`git submodule foreach 'git checkout -q master'`
      `git submodule foreach 'git pull'`
    end

    desc "Run all update tasks"
    task :all => [
      "update:remove_old_submodules",
      "update:files",
      #"update:fix_inheritance",
      #"update:fix_migrations",
      "update:migrations",
      "update:gems"
    ]
  end

  desc "Automated updates for newest version"
  task :update => ["update:submodules"] do
    puts "Submodules updated, running rake again"
    system "bundle exec rake pages:update:all"
  end
end
