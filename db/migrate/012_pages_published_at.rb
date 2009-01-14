class PagesPublishedAt < ActiveRecord::Migration
        def self.up
                add_column :pages, :published_at, :datetime
                add_column :pages, :redirect_to,  :text
        end

        def self.down
                remove_column :pages, :published_at
                remove_column :pages, :redirect_to
        end
end
