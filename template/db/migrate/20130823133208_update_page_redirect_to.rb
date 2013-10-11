class UpdatePageRedirectTo < ActiveRecord::Migration

  def self.up
    include Rails.application.routes.url_helpers

    pages = Page.where('redirect_to IS NOT NULL AND redirect_to != ""')
    pages.each do |page|
      if page.redirect_to == "0" || page.redirect_to == "--- \"\"\n"
        page.update_attributes(redirect_to: nil)
      elsif page.redirect_to.start_with?("---")
        options = YAML.load(page.redirect_to)
        path = url_for(options.merge({locale: ':locale', only_path: true}))
        page.update_attributes(redirect_to: path)
      elsif !(page.redirect_to =~ /\A(\/|https?:\/\/)/)
        raise "Not a valid Page redirect_to: #{page.redirect_to.inspect}"
      end
    end
    change_column :pages, :redirect_to, :string
  end

  def self.down
    change_column :pages, :redirect_to, :text
  end
end
