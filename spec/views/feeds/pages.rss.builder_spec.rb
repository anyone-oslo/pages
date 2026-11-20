# frozen_string_literal: true

require "rails_helper"

describe "feeds/pages" do
  let(:items) { [] }
  let(:feed) { Nokogiri::XML(rendered) }

  before do
    assign(:items, items)
    without_partial_double_verification do
      allow(view).to receive(:root_url).and_return("http://test.host/")
    end
    render template: "feeds/pages", formats: [:rss]
  end

  it "renders the language as an element" do
    expect(rendered).to include("<language>#{I18n.locale}</language>")
  end

  describe "media:description" do
    subject(:descriptions) do
      feed.xpath("//item/media:content/media:description",
                 "media" => "http://search.yahoo.com/mrss/")
    end

    let(:items) do
      [create(:page, page_images_attributes: [{ image_id: image.id, primary: true }])]
    end

    context "when the image has alternative text" do
      let(:image) do
        create(:image, alternative: "A blue square",
                       locale: I18n.default_locale)
      end

      it { is_expected.to contain_exactly(have_attributes(text: "A blue square")) }
    end

    context "when the image is decorative" do
      let(:image) do
        create(:image, decorative: true, locale: I18n.default_locale)
      end

      it { is_expected.to contain_exactly(have_attributes(text: "")) }
    end

    context "when a decorative image has alternative text" do
      let(:image) do
        create(:image, decorative: true, alternative: "A blue square",
                       locale: I18n.default_locale)
      end

      it { is_expected.to contain_exactly(have_attributes(text: "")) }
    end

    context "when the image has no alternative text" do
      let(:image) { create(:image, locale: I18n.default_locale) }

      it { is_expected.to be_empty }
    end
  end
end
