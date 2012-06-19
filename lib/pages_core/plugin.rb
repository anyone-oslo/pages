module PagesCore
  class Plugin
    @@plugins = []
    def self.inherited(plugin)
      @@plugins << plugin
    end
  end
end