# frozen_string_literal: true

require "rails_helper"

describe PagesCore do
  it "has a plugin_root" do
    expect(described_class.plugin_root).to be_a(Pathname)
  end
end
