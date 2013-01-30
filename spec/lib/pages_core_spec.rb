# encoding: utf-8

require 'spec_helper'

describe PagesCore do
  it 'has a plugin_root' do
    PagesCore.plugin_root.should be_kind_of(Pathname)
  end
end
