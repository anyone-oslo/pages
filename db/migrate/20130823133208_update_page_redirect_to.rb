# encoding: utf-8

class UpdatePageRedirectTo < ActiveRecord::Migration
  def self.up
    include Rails.application.routes.url_helpers
    change_column :pages, :redirect_to, :string
  end

  def self.down
    change_column :pages, :redirect_to, :text
  end
end
