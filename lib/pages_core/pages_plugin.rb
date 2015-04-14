# encoding: utf-8

module PagesCore
  class PagesPlugin < Plugin
    paths["db/migrate"] = "db/migrate"

    admin_menu_item "News",  proc { news_admin_pages_path(@locale) }, :pages,
                    if:      proc { Page.news_pages.any? },
                    current: proc { @page && @page.parent.try(&:news_page?) }

    admin_menu_item "Pages", proc { admin_pages_path(@locale) }, :pages
    admin_menu_item "Users", proc { admin_users_path }, :account
  end
end
