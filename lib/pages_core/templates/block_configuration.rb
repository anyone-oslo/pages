module PagesCore
  module Templates
    # Configuration for the blocks on an individual template
    class BlockConfiguration
      attr_reader :name, :title, :description, :optional, :enforced
      def small?
        @size == :small
      end

      def large?
        small? ? false : true
      end
    end
  end
end
