# frozen_string_literal: true

class EnableSearchExtensions < ActiveRecord::Migration[5.2]
  def change
    ActiveRecord::Base.connection.execute <<~SQL.squish
      CREATE EXTENSION IF NOT EXISTS unaccent;
      CREATE EXTENSION IF NOT EXISTS pg_trgm;
    SQL
  end
end
