# encoding: utf-8

module PagesCore
  module Templates
    module ControllerActions
      extend ActiveSupport::Concern

      module ClassMethods
        def template_actions
          @template_actions ||= Hash.new { |hash, key| hash[key] = [] }
        end

        def template(*names, &block)
          Array(names).each do |name|
            name = name.to_s unless name == :all
            template_actions[name] << block
          end
        end

        def template_actions_for(name)
          template_actions[:all] + template_actions[name.to_s]
        end
      end

      def run_template_actions_for(template, *args)
        self.class.template_actions_for(template).each do |proc|
          instance_exec(*args, &proc)
        end
      end
    end
  end
end
