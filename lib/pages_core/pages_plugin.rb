# encoding: utf-8

module PagesCore
  class PagesPlugin < Plugin
    paths['db/migrate'] = 'template/db/migrate'

    admin_menu_item "News",  Proc.new { news_admin_pages_path(@locale) }, :pages,
      if:      Proc.new { Page.news_pages.any? },
      current: Proc.new { @page && @page.parent.try(&:news_page?) }

    admin_menu_item "Pages", Proc.new { admin_pages_path(@locale) }, :pages
    admin_menu_item "Users", Proc.new { admin_users_path }, :account
  end
end
