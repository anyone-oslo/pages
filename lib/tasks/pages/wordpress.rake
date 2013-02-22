# encoding: utf-8

namespace :pages do
  namespace :wordpress do

    desc "Import WordPress content"
    task :import => :environment do

      def get_input(prompt='', default='')
        print "#{prompt} [#{default}]: "
        input = STDIN.readline.chomp
        input.empty? ? default : input
      end

      def get_input_yn(prompt, default=false)
        default_text = default ? 'y' : 'n'
        value = get_input(prompt, default_text)
        value =~ /^[yY]/ ? true : false
      end

      def post_to_params(post)
        params = {}
        params[:name]       = post['post_title']   unless post['post_title'].blank?
        params[:excerpt]    = post['post_excerpt'] unless post['post_excerpt'].blank?
        params[:body]       = post['post_content'] unless post['post_content'].blank?
        params[:created_at] = DateTime.parse(post['post_date']) unless post['post_date'].blank?
        params[:updated_at] = post['post_modified'].blank? ? params[:created_at] : DateTime.parse(post['post_modified'])

        params[:post_author] = post['post_author']  unless post['post_author'].blank?

        params[:youtube_id]  = post['youtube']  unless post['youtube'].blank?

        params[:status] = 2 if post['post_status'] == 'publish'
        params
      end

      table_prefix    = get_input('Table prefix', 'wp')
      import_users    = get_input_yn('Import users', true)
      unless import_users
        first_user_id = User.find(:first).id.to_s
        default_user_id = get_input('Author ID', first_user_id)
        default_user = User.find(default_user_id)
      end
      import_pages    = get_input_yn('Import pages', true)
      post_parent_id  = get_input('Parent page for posts', 'root')
      import_language = get_input('Language', Language.default)
      import_images   = get_input_yn('Import images', true)
      import_comments = get_input_yn('Import comments', true)
      import_youtube  = get_input_yn('Import video embed tags', true)

      @convert_encoding = get_input_yn('Convert encoding', false)
      if @convert_encoding
        @convert_from = get_input('Convert from', 'iso-8859-1')
        @convert_to   = get_input('Convert to', 'utf-8')
      end


      puts ""

      @wp_tables = {
        :comments           => "#{table_prefix}_comments",
        :links              => "#{table_prefix}_links",
        :options            => "#{table_prefix}_options",
        :postmeta           => "#{table_prefix}_postmeta",
        :posts              => "#{table_prefix}_posts",
        :term_relationships => "#{table_prefix}_term_relationships",
        :term_taxonomy      => "#{table_prefix}_term_taxonomy",
        :terms              => "#{table_prefix}_terms",
        :usermeta           => "#{table_prefix}_usermeta",
        :users              => "#{table_prefix}_users",
        :votes              => "#{table_prefix}_votes",
        :votes_users        => "#{table_prefix}_votes_users",
      }

      def get_rows(table_key)
        table_name = @wp_tables[table_key]
        @table_fields ||= {}
        @table_rows   ||= {}
        @table_fields[table_name] ||= ActiveRecord::Base.connection.select_rows("DESC `#{table_name}`").map{|r| r[0]}
        unless @table_rows[table_name]
          rows = ActiveRecord::Base.connection.select_rows("SELECT * FROM `#{table_name}`")
          @table_rows[table_name] = rows.map do |row|
            hash = {}
            row.each_with_index do |value, i|
              if @convert_encoding
                raise "Need to fix encoding conversion"
                #value = Iconv.conv(@convert_to, @convert_from, value)
              end
              hash[@table_fields[table_name][i]] = value
            end
            hash
          end
        end
        @table_rows[table_name]
      end

      # Users
      puts "Loading users..."
      users = {}
      get_rows(:users).each do |row|
        user_id = row['ID']
        if import_users
          unless pages_user = User.find_by_username(row['user_nicename'])
            pages_user = User.create(
              :email        => row['user_email'],
              :username     => row['user_nicename'],
              :realname     => row['display_name'],
              :is_admin     => true,
              :is_activated => true
            )
            pages_user.generate_new_password
            pages_user.save
            unless pages_user.valid?
              puts "Invalid user: #{row.inspect}"
            end
          end
        else
          pages_user = default_user
        end
        users[user_id] = pages_user
      end

      puts "Loading tags and categories..."
      terms = {}
      get_rows(:terms).each do |term|
        term_id = term['term_id']
        terms[term_id] = term
      end
      get_rows(:term_taxonomy).each do |row|
        term_id = row['term_id']
        if terms[term_id]
          if row['taxonomy'] == 'category'
            terms[term_id]['type'] = 'category'
          elsif row['taxonomy'] == 'post_tag'
            terms[term_id]['type'] = 'tag'
          end
          terms[term_id]['taxonomies'] ||= []
          terms[term_id]['taxonomies'] << row['term_taxonomy_id']
        end
      end
      terms.each do |term_id, term|
        if term['type'] == 'category'
          unless term['category'] = Category.find_by_name(term['name'])
            term['category'] = Category.create(:name => term['name'])
          end
        elsif term['type'] == 'tag'
          unless term['tag'] = Tag.find_by_name(term['name'])
            term['tag'] = Tag.create(:name => term['name'])
          end
        end
        terms[term_id] = term
      end

      puts "Loading posts..."
      posts = {}
      get_rows(:posts).each do |post|
        post_id = post['ID']
        if posts[post['post_parent']]
          if post['post_type'] =~ /^revision$/
            posts[post['post_parent']][:revisions] ||= []
            posts[post['post_parent']][:revisions] << post_id
          elsif post['post_type'] =~ /^attachment$/
            posts[post['post_parent']][:attachment] ||= []
            posts[post['post_parent']][:attachment] << post_id
          end
        end
        posts[post_id] = post
      end
      get_rows(:term_relationships).each do |row|
        post_id = row['object_id']
        taxonomy_id = row['term_taxonomy_id']
        if posts[post_id]
          term = terms.select{|id, term| term['taxonomies'].include?(taxonomy_id)}.first rescue nil
          if term
            posts[post_id][:terms] ||= []
            posts[post_id][:terms] << term
          end
        end
      end
      get_rows(:postmeta).each do |row|
        post_id = row['post_id']
        if posts[post_id]
          if row['meta_key'] =~ /^youtube$/
            posts[post_id]['youtube'] = row['meta_value']
          end
        end
      end

      puts "Building pages..."
      posts.each do |post_id, post|
        if post['post_type'] =~ /^post$/ || (import_pages && post['post_type'] =~ /^page$/)
          params = post_to_params(post)
          if post[:revisions] && post[:revisions].length > 0
            post[:revisions].map{|s| s.to_i}.sort.map{|i| i.to_s}.each do |revision_id|
              if posts[revision_id]
                revision = posts[revision_id]
                params = params.merge(post_to_params(revision))
                unless revision['post_parent'].blank?
                  post['post_parent'] = revision['post_parent']
                end
              end
            end
          end

          post[:page] = Page.new.translate(import_language)

          if params[:post_author]
            params[:user_id] = users[params[:post_author]].id
            params.delete(:post_author)
          end

          if params[:youtube_id]
            if import_youtube
              params[:video_embed] = "<object width=\"480\" height=\"385\"><param name=\"movie\" value=\"http://www.youtube.com/v/#{params[:youtube_id]}\"></param><param name=\"allowFullScreen\" value=\"true\"></param><param name=\"allowscriptaccess\" value=\"always\"></param><embed src=\"http://www.youtube.com/v/#{params[:youtube_id]}\" type=\"application/x-shockwave-flash\" allowscriptaccess=\"always\" allowfullscreen=\"true\" width=\"480\" height=\"385\"></embed></object>"
            end
            params.delete(:youtube_id)
          end

          params[:published_at] = params[:created_at]

          post[:page].attributes = params

          unless post[:page].valid?
            puts "Invalid!"
          end

          posts[post_id] = post
        end
      end

      puts "Saving pages..."
      posts.each do |post_id, post|
        if post[:page]
          post[:page].save
          post[:page] = Page.find(post[:page].id)
        end
      end

      puts "Building relations..."
      posts.each do |post_id, post|
        if post[:page]

          if post['post_type'] =~ /^page$/
            if post['post_parent'] && posts[post['post_parent']] && posts[post['post_parent']][:page]
              post[:page].update_attribute(:parent_page_id, posts[post['post_parent']][:page].id)
            end
          else
            if post_parent_id && post_parent_id =~ /^[\d]+$/
              post[:page].update_attribute(:parent_page_id, post_parent_id.to_i)
            end
          end

          if post[:terms]
            post[:terms].each do |term_id, term|
              if term['type'] == 'tag'
                post[:page].tags << term['tag']
              elsif term['type'] == 'category'
                post[:page].categories << term['category']
              end
            end
          end

        end
      end

      if import_images
        puts "Importing images (this might take a while)..."
        bad_images = []
        posts.each do |post_id, post|
          if post[:page] && post[:attachment] && post[:attachment].length > 0
            post[:attachment].map{|s| s.to_i}.sort.map{|i| i.to_s}.each do |attachment_id|
              if posts[attachment_id]
                attachment = posts[attachment_id]
                if attachment['post_mime_type'] =~ /^image/
                  image_url = attachment['guid']
                  begin
                    filename = image_url.split("/").last
                    image = Image.create(
                      :filename     => filename,
                      :content_type => attachment['post_mime_type'],
                      :data         => open(image_url).read
                    )
                    if image.valid?
                      if post[:page].image
                        post[:page].images << image
                      else
                        post[:page].update_attribute(:image_id, image.id)
                      end
                    end
                  rescue
                    bad_images << image_url
                  end
                end
              end
            end
          end
        end
        if bad_images.length > 0
          puts "Warning: #{bad_images.length} bad images not imported"
        end
      end

      if import_comments
        puts "Importing comments..."
        get_rows(:comments).each do |comment|
          if posts[comment['comment_post_ID']] && posts[comment['comment_post_ID']][:page]
            if comment['comment_approved'] == '1' && comment['comment_type'] != 'pingback'
              post = posts[comment['comment_post_ID']]
              params = {}
              params[:remote_ip]  = comment['comment_author_IP']
              params[:name]       = comment['comment_author'] unless comment['comment_author'].blank?
              params[:body]       = comment['comment_content'] unless comment['comment_content'].blank?
              params[:email]      = comment['comment_author_email'] unless comment['comment_author_email'].blank?
              params[:url]        = comment['comment_author_url'] unless comment['comment_author_url'].blank?
              params[:created_at] = DateTime.parse(comment['comment_date'])
              params[:updated_at] = params[:created_at]
              post[:page].comments.create(params)
            end
          end
        end
      end

      puts "All done!"
      puts ""
      if get_input_yn('Delete Wordpress tables?', false)
        @wp_tables.each do |key, table_name|
          ActiveRecord::Base.connection.drop_table table_name rescue nil
        end
        puts "Wordpress tables deleted."
      end

    end
  end
end
