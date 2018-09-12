class IndexTemplate < ApplicationTemplate
  filename "default"
  name "Default"
  images true
  enabled_blocks []

  render do |_|
    "foo"
  end
end
