# encoding: utf-8

require 'digest/sha1'

class DynamicImageBinaryObjects < ActiveRecord::Migration
	def self.up
		add_column :binaries, :sha1_hash, :string

		dump_dir = File.join('/tmp', Digest::SHA1.hexdigest((Time.now + rand(65535)).to_s))

		`mkdir -p #{dump_dir}`
		if File.exists?(dump_dir)
			`chmod a+rwx #{dump_dir}`
			binary_ids = Binary.find_by_sql("SELECT id FROM binaries").map{|b| b.id}
			binary_ids.each do |id|
				# Dump file
				dump_file = File.join(dump_dir, id.to_s)
				unless File.exists?(dump_file)
					query = "SELECT data FROM binaries WHERE id = #{id} INTO DUMPFILE \""+dump_file+"\""
					ActiveRecord::Base.connection.execute(query)
				end
				# Get SHA1 hash of content
				sha1_hash = `#{DynamicImage.sha1sum_path} #{dump_file}`.split(/\s+/).first
				# Move file to proper location
				target_file = Binary.storage_path(sha1_hash)
				if File.exists?(target_file)
					`rm #{dump_file}`
				else
					`mkdir -p #{Binary.storage_dir(sha1_hash)}`
					`mv #{dump_file} #{target_file}`
				end
				# Update record
				ActiveRecord::Base.connection.update_sql("UPDATE binaries SET sha1_hash = \"#{sha1_hash}\" WHERE id = #{id}")
			end
			`rm -rf #{dump_dir}`

			remove_column :binaries, :data
		else
			raise "Unable to create temporary dump dir!"
		end
	end

	def self.down
		add_column :binaries, :data, :binary, :limit => 100.megabytes
		Binary.find(:all).each do |b|
			if File.exists?(b.storage_path)
				File.open(b.storage_path) do |fh|
					b.update_attribute(:data, fh.read)
				end
				`rm #{b.storage_path}`
			end
		end
		remove_column :binaries, :sha1_hash
	end
end
