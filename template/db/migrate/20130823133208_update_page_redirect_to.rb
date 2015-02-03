# encoding: utf-8

class UpdatePageRedirectTo < ActiveRecord::Migration

  def self.up
    pages = Page.find(:all, :conditions => ['redirect_to IS NOT NULL AND redirect_to != ""'])
    rewriter = ActionController::UrlRewriter.new(ActionController::Request.new({}), {})
    pages.each do |page|
      if page.redirect_to == "0"
        page.update_attributes(:redirect_to => nil)
      elsif page.redirect_to.start_with?("---")
        options = YAML.load(page.redirect_to)
        path = rewriter.send(:rewrite_path, options.merge({:language => ':locale'}))
        page.update_attributes(:redirect_to => path)
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
