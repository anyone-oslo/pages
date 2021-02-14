# frozen_string_literal: true

class CreateSearchDocuments < ActiveRecord::Migration[6.0]
  def change
    create_table :search_documents do |t|
      t.references :searchable, polymorphic: true, index: true, null: false
      t.string :locale, null: false

      t.text :name
      t.text :description
      t.text :content
      t.text :tags
      t.boolean :published, null: false, default: true
      t.timestamps
      t.datetime :record_updated_at, null: false

      t.index %i[searchable_type searchable_id locale],
              name: :search_documents_unique_index,
              unique: true

      # Tsvector index
      t.string :tsv_config, null: false, default: "simple_unaccent"
      t.tsvector :tsv
      t.index :tsv, using: :gin

      # Trigram index
      t.index :name,
              name: :search_documents_trgm_idx,
              using: :gin,
              opclass: { title: :gin_trgm_ops }
    end

    reversible do |dir|
      dir.up do
        ActiveRecord::Base.connection.execute <<-SQL.squish
          DROP FUNCTION IF EXISTS tsvector_search_documents_trigger;
          CREATE FUNCTION tsvector_search_documents_trigger()
            RETURNS trigger AS $$
            begin
              new.tsv :=
                setweight(to_tsvector(new.tsv_config::regconfig,
                                      coalesce(new.name, '')), 'A') ||
                setweight(to_tsvector(new.tsv_config::regconfig,
                                      coalesce(new.description, '')), 'B') ||
                setweight(to_tsvector(new.tsv_config::regconfig,
                                      coalesce(new.content, '')), 'C') ||
                setweight(to_tsvector(new.tsv_config::regconfig,
                                      coalesce(new.tags, '')), 'B');
              return new;
            end
            $$ LANGUAGE plpgsql;

          DROP TRIGGER IF EXISTS tsvector_search_documents_update
            ON search_documents;

          CREATE TRIGGER tsvector_search_documents_update
            BEFORE INSERT OR UPDATE
            ON search_documents FOR EACH ROW EXECUTE PROCEDURE
            tsvector_search_documents_trigger();
        SQL

        # Index all pages
        Page.all.find_each do |p|
          PagesCore::SearchableDocument::Indexer.new(p).index!
        end
      end
      dir.down do
        ActiveRecord::Base.connection.execute <<-SQL.squish
          DROP TRIGGER IF EXISTS tsvector_search_documents_update
            ON search_documents;
          DROP FUNCTION IF EXISTS tsvector_search_documents_trigger;
        SQL
      end
    end
  end
end
