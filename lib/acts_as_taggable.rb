# encoding: utf-8

module ActiveRecord
	module Acts #:nodoc:
		module Taggable #:nodoc:
			def self.included(base)
				base.extend(ClassMethods)
				base.instance_eval do
					attr_accessor :serialized_tags
				end
			end

			module ClassMethods
				def acts_as_taggable(options = {})
					write_inheritable_attribute(:acts_as_taggable_options, {
						:taggable_type => ActiveRecord::Base.send(:class_name_of_active_record_descendant, self).to_s,
						:from => options[:from]
					})

					class_inheritable_reader :acts_as_taggable_options

					has_many :taggings, :as => :taggable, :dependent => :destroy
					has_many :tags, :through => :taggings

					include ActiveRecord::Acts::Taggable::InstanceMethods
					extend ActiveRecord::Acts::Taggable::SingletonMethods
				end
			end

			module SingletonMethods
				def find_tagged_with(list=[])
					if list.kind_of?(String) || !list.kind_of?(Enumerable)
						list = [list]
					end
					list = list.map do |item|
						item = item.name if item.kind_of?(Tag)
						item
					end
					find_by_sql([
						"SELECT #{table_name}.* FROM #{table_name}, tags, taggings " +
						"WHERE #{table_name}.#{primary_key} = taggings.taggable_id " +
						"AND taggings.taggable_type = ? " +
						"AND taggings.tag_id = tags.id AND tags.name IN (?)",
						acts_as_taggable_options[:taggable_type], list
					])
				end
			end

			module InstanceMethods

				def serialized_tags=(serialized_tags)
					Tag.transaction do
						taggings.destroy_all
						tag_names = ActiveSupport::JSON.decode(serialized_tags)
						tag_names.each do |name|
							if acts_as_taggable_options[:from]
								send(acts_as_taggable_options[:from]).tags.find_or_create_by_name(name).on(self)
							else
								Tag.find_or_create_by_name(name).on(self)
							end
						end
					end
				end

				def tag_with(list)
					Tag.transaction do
						taggings.destroy_all
						Tag.parse(list).each do |name|
							if acts_as_taggable_options[:from]
								send(acts_as_taggable_options[:from]).tags.find_or_create_by_name(name).on(self)
							else
								Tag.find_or_create_by_name(name).on(self)
							end
						end
					end
				end

				def tag_list
					#tags.collect { |tag| tag.name.include?(" ") ? "'#{tag.name}'" : tag.name }.join(", ")
					tags.map{|t| t.name }.join(", ")
				end

				def tags?
					(self.taggings.count > 0) ? true : false
				end
			end
		end
	end
end

ActiveRecord::Base.send(:include, ActiveRecord::Acts::Taggable)