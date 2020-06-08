# frozen_string_literal: true

class UpdatePageRedirectTo < ActiveRecord::Migration[4.2]
  def self.up
    include Rails.application.routes.url_helpers
    change_column :pages, :redirect_to, :string
  end

  def self.down
    change_column :pages, :redirect_to, :text
  end
end
