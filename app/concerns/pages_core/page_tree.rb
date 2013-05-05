module PagesCore
  module PageTree
    extend ActiveSupport::Concern

    included do
      belongs_to :parent,
                 :class_name  => 'Page',
                 :foreign_key => :parent_page_id,
                 :inverse_of  => :children

      has_many   :children,
                 :class_name  => 'Page',
                 :foreign_key => :parent_page_id,
                 :inverse_of  => :parent,
                 :dependent   => :destroy
    end

    module ClassMethods
      # Returns all root pages
      def roots
        where(:parent_page_id => nil).order('position ASC')
      end

      # Returns the first root page
      def root
        roots.first
      end
    end

    # Returns list of ancestors, starting from parent until root.
    #
    #   subchild1.ancestors # => [child1, root]
    def ancestors
      node, nodes = self, []
      nodes << node = node.parent while node.parent
      nodes
    end

    # Returns the pages parent
    def parent
      super.try { |node| node.localize(self.locale) }
    end

    # Returns the root node of the tree.
    def root
      node = self
      node = node.parent while node.parent
      node
    end

    # Returns ancestors and current node itself.
    #
    #   subchild1.self_and_ancestors # => [subchild1, child1, root]
    def self_and_ancestors
      [self] + self.ancestors
    end

  end
end