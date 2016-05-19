# encoding: utf-8

module PagesCore
  module PageModel
    module Tree
      extend ActiveSupport::Concern

      included do
        belongs_to :parent,
                   class_name:  "Page",
                   foreign_key: :parent_page_id,
                   inverse_of:  :children

        has_many :children,
                 class_name:  "Page",
                 foreign_key: :parent_page_id,
                 inverse_of:  :parent,
                 dependent:   :destroy

        # This must be included after the belongs_to call in order
        # to override the .parent method.
        include PagesCore::PageModel::Tree::InstanceMethods
      end

      module ClassMethods
        # Returns all root pages
        def roots
          where(parent_page_id: nil).order("position ASC")
        end

        # Returns the first root page
        def root
          roots.first
        end
      end

      module InstanceMethods
        # Returns list of ancestors, starting from parent until root.
        #
        #   subchild1.ancestors # => [child1, root]
        def ancestors
          node = self
          nodes = []
          nodes << node = node.parent while node.parent
          nodes
        end

        # Returns all children, recursively
        def all_subpages
          return nil unless subpages.any?
          localized_subpages.map { |p| [p, p.all_subpages] }.flatten.compact
        end

        def localized_subpages
          return subpages unless locale?
          subpages.localized(locale)
        end

        # Finds the page's next sibling. Returns nil if there isn't one.
        def next_sibling
          return unless siblings.any?
          siblings[(siblings.index(self) + 1)...siblings.length].try(&:first)
        end

        # Returns the pages parent
        def parent
          super.try { |node| node.localize(locale) }
        end

        # Get subpages
        def pages(_options = nil)
          localized_subpages.published
        end

        # Finds the page's next sibling. Returns nil if there isn't one.
        def previous_sibling
          return unless siblings.any?
          siblings[0...siblings.index(self)].try(&:last)
        end

        # Returns the root node of the tree.
        def root
          self_and_ancestors.last
        end

        # Returns ancestors and current node itself.
        #
        #   subchild1.self_and_ancestors # => [subchild1, child1, root]
        def self_and_ancestors
          [self] + ancestors
        end

        # Returns all siblings, including self.
        def siblings
          if parent
            parent.pages
          else
            self.class.roots.map { |node| node.localize(locale) }
          end
        end

        def subpages
          children.order(content_order)
        end
      end
    end
  end
end
