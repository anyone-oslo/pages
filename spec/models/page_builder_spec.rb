require "rails_helper"

describe PageBuilder do
  let(:user) { create(:user) }
  let(:locale) { I18n.default_locale }
  let(:page1) { Page.first.localize(locale) }
  let(:page2) { page1.children.first }
  let(:page3) { page1.children.last }

  describe ".build" do
    before do
      described_class.build(user, locale: locale) do
        page "Home" do
          page "Foo"
          page "Bar", template: "foobar", status: 1
        end
      end
    end

    it "creates the page" do
      expect(Page.count).to eq(3)
    end

    specify { expect(page1.name).to eq("Home") }
    specify { expect(page1.template).to eq("index") }
    specify { expect(page1.published?).to eq(true) }
    specify { expect(page1.parent).to eq(nil) }
    specify { expect(page1.author).to eq(user) }

    specify { expect(page2.parent).to eq(page1) }
    specify { expect(page2.author).to eq(user) }

    specify { expect(page3.template).to eq("foobar") }
    specify { expect(page3.published?).to eq(false) }
  end
end
