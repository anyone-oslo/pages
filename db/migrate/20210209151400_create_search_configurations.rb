# frozen_string_literal: true

class CreateSearchConfigurations < ActiveRecord::Migration[5.2]
  def up
    dictionaries.each do |dict|
      stem = dict == "simple" ? "simple" : "#{dict}_stem"

      ActiveRecord::Base.connection.execute <<-SQL.squish
        DROP TEXT SEARCH CONFIGURATION IF EXISTS #{dict}_unaccent;
        CREATE TEXT SEARCH CONFIGURATION #{dict}_unaccent
          (COPY = pg_catalog.#{dict});
        ALTER TEXT SEARCH CONFIGURATION #{dict}_unaccent
          ALTER MAPPING FOR hword, hword_part, word
          WITH unaccent, #{stem};
      SQL
    end
  end

  def down
    dictionaries.each do |dict|
      ActiveRecord::Base.connection.execute <<-SQL.squish
        DROP TEXT SEARCH CONFIGURATION IF EXISTS #{dict}_unaccent;
      SQL
    end
  end

  private

  def dictionaries
    %w[arabic danish dutch english finnish french german greek
       hungarian indonesian irish italian lithuanian nepali
       norwegian portuguese romanian russian spanish swedish
       tamil turkish simple]
  end
end
