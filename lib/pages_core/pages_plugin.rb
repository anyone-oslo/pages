# encoding: utf-8

module PagesCore
  class PagesPlugin < Plugin
    paths['db/migrate'] = 'template/db/migrate'
  end
end
