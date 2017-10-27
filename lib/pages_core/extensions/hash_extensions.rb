module PagesCore
  module Extensions
    module HashExtensions
      def deep_merge(hash)
        target = dup

        hash.keys.each do |key|
          if hash[key].is_a?(Hash) && self[key].is_a?(Hash)
            target[key] = target[key].deep_merge(hash[key])
            next
          end

          target[key] = hash[key]
        end

        target
      end
    end
  end
end
Hash.send(:include, PagesCore::Extensions::HashExtensions)
