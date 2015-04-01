# encoding: utf-8

# Be sure to restart your web server when you modify this file.

PagesCore::CacheSweeper.config do |_sweeper|
  # Observed models
  # sweeper.observe  += [Artist, Song]

  # Path patterns
  # sweeper.patterns += [/^\/archive(.*)$/, /^\/tests(.*)$/]
end
