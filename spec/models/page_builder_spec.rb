# encoding: utf-8

require "spec_helper"

describe PageBuilder do
  let(:user) { create(:user) }
  let(:locale) { I18n.default_locale }
  let(:page1) { Page.first.localize(locale) }
  let(:page2) { page1.children.first }
  let(:page3) { page1.children.last }

  describe ".build" do
    before do
      PageBuilder.build(user, locale: locale) do
        page "Home" do
          page "Foo"
          page "Bar", template: "foobar", status: 1
        end
      end
    end

    it "should create the page" do
      expect(Page.count).to eq(3)
    end

    it "should set the correct default options" do
      expect(page1.name).to eq("Home")
      expect(page1.template).to eq("index")
      expect(page1.published?).to eq(true)
      expect(page1.parent).to eq(nil)
      expect(page1.author).to eq(user)
    end

    it "should inherit parent on nested pages" do
      expect(page2.parent).to eq(page1)
      expect(page2.author).to eq(user)
    end

    it "should set the options when provided" do
      expect(page3.template).to eq("foobar")
      expect(page3.published?).to eq(false)
    end
  end
end
