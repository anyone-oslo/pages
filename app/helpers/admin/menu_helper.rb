# encoding: utf-8

module Admin
  module MenuHelper
    def header_tabs(group)
      content_tag :ul, class: group.to_s do
        safe_join(menu_items_for(group).map do |item|
          content_tag :li do
            path = instance_eval(&item.path)
            link_to(item.label,
                    path,
                    class: (current_menu_item?(item) ? "current" : ""))
          end
        end)
      end
    end

    protected

    def menu_item_candidates
      routed_menu_items
        .select { |_, routing| routing[:controller] == params[:controller] }
    end

    def find_menu_candidate
      menu_item_candidates
        .select { |item, routing| yield(item, routing) }
        .try(&:first)
        .try(&:first)
    end

    def menu_candidate_by_current_proc
      find_menu_candidate do |item, _|
        item.options[:current] && instance_eval(&item.options[:current])
      end
    end

    def current_menu_item
      menu_candidate_by_current_proc ||
        find_menu_candidate { |_, r| r[:action] == params[:action] } ||
        find_menu_candidate { |_, r| r[:action] == "index" } ||
        find_menu_candidate { |_, _| true }
    end

    def current_menu_item?(item)
      item == current_menu_item
    end

    def menu_items
      PagesCore::AdminMenuItem.items
    end

    def menu_items_for(group)
      menu_items
        .select { |item| item.group == group }
        .reject do |item|
          item.options[:if] && !instance_eval(&item.options[:if])
        end
    end

    def routed_menu_items
      routes = Rails.application.routes
      menu_items
        .select { |item| item.path.is_a?(Proc) }
        .map { |item| [item, routes.recognize_path(instance_eval(&item.path))] }
    end
  end
end
