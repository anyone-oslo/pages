module PagesCore
  class PagesPlugin < Plugin
    paths['db/migrate'] = 'template/db/migrate'
  end
end
