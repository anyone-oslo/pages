# Derived from the Gibberish plugin, which is copyright (c) 2007 Chris Wanstrath.
# http://plugins.require.errtheblog.com/browser/gibberish

require 'mumbojumbo/localize'
require 'mumbojumbo/string_ext'

String.send :include, MumboJumbo::StringExt

module MumboJumbo
  extend Localize
end
