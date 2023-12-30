# frozen_string_literal: true

require "rails_helper"

describe PageBuilder do
  let(:user) { create(:user) }
  let(:locale) { I18n.default_locale }
  let(:root) { Page.first.localize(locale) }
  let(:foo) { root.children.first }
  let(:bar) { root.children.last }

  describe ".build" do
    before do
      described_class.build(user, locale:) do
        page "Home" do
          page "Foo"
          page "Bar", template: "foobar", status: 1
        end
      end
    end

    it "creates the page" do
      expect(Page.count).to eq(3)
    end

    specify { expect(root.name).to eq("Home") }
    specify { expect(root.template).to eq("index") }
    specify { expect(root.published?).to be(true) }
    specify { expect(root.parent).to be_nil }
    specify { expect(root.author).to eq(user) }

    specify { expect(foo.parent).to eq(root) }
    specify { expect(foo.author).to eq(user) }

    specify { expect(bar.template).to eq("foobar") }
    specify { expect(bar.published?).to be(false) }
  end
end
