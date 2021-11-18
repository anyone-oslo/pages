# frozen_string_literal: true

module PagesCore
  unless PagesCore.const_defined?("VERSION")
    VERSION = File.read(File.expand_path("../../VERSION", __dir__)).strip
  end
end
