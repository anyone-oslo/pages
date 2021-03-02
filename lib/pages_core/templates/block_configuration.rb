# frozen_string_literal: true

module PagesCore
  module Templates
    # Configuration for the blocks on an individual template
    class BlockConfiguration
      attr_reader :name, :title, :description, :optional, :enforced

      def small?
        @size == :small
      end

      def large?
        !small?
      end
    end
  end
end
