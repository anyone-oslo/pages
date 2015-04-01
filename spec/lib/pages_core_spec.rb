# encoding: utf-8

require "spec_helper"

describe PagesCore do
  it "has a plugin_root" do
    expect(PagesCore.plugin_root).to be_kind_of(Pathname)
  end
end
