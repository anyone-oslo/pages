# encoding: utf-8

module Admin::MenuHelper

  def header_tabs(group)
    content_tag :ul, class: group.to_s do
      menu_items_for(group).map do |item|
        content_tag :li do
          path = instance_eval(&item.path)
          link_to item.label, path, class: (current_menu_item?(item) ? "current" : "")
        end
      end.join.html_safe
    end
  end

  protected

  def menu_item_candidates
    routes = Rails.application.routes
    menu_items.map { |item| [item, routes.recognize_path(instance_eval(&item.path))] }
      .select { |item, routing| routing[:controller] == params[:controller] }
  end

  def current_menu_item
    @_current_menu_item ||= Proc.new {
      menu_item_candidates.each do |item, routing|
        if item.options[:current] && instance_eval(&item.options[:current])
          return item
        elsif routing[:action] == params[:action]
          return item
        end
      end

      if candidate = menu_item_candidates.select { |item, routing| routing[:action] == "index" }.try(&:first)
        return candidate.first
      elsif candidate = menu_item_candidates.try(&:first)
        return candidate.first
      end
    }.call
  end

  def current_menu_item?(item)
    item == current_menu_item
  end

  def menu_items
    PagesCore::AdminMenuItem.items
  end

  def menu_items_for(group)
    menu_items.select {|item| item.group == group }
      .reject { |item| item.options[:if] && !instance_eval(&item.options[:if]) }
  end

end