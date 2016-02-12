require "rails_helper"

RSpec.describe PagesCore::OpenGraphTagsHelper, type: :helper do
  let(:page) do
    build(:page, open_graph_title: "Article", open_graph_description: "desc")
  end

  describe "#open_graph_tags" do
    subject { helper.open_graph_tags }

    it "should render the open graph tags" do
      expect(subject).to eq(
        "<meta property=\"og:type\" content=\"website\" />\n" \
          "<meta property=\"og:site_name\" content=\"Pages Site\" />\n" \
          "<meta property=\"og:title\" content=\"Pages Site\" />\n" \
          "<meta property=\"og:url\" content=\"http://test.host\" />"
      )
    end

    context "with a page" do
      before { helper.instance_variable_set(:@page, page) }
      it "should render the open graph tags" do
        expect(subject).to eq(
          "<meta property=\"og:type\" content=\"website\" />\n" \
            "<meta property=\"og:site_name\" content=\"Pages Site\" />\n" \
            "<meta property=\"og:title\" content=\"Article\" />\n" \
            "<meta property=\"og:description\" content=\"desc\" />\n" \
            "<meta property=\"og:url\" content=\"http://test.host\" />"
        )
      end
    end

    context "with an image" do
      before { helper.meta_image "foo.png" }
      it "should render the open graph tags" do
        expect(subject).to eq(
          "<meta property=\"og:type\" content=\"website\" />\n" \
            "<meta property=\"og:site_name\" content=\"Pages Site\" />\n" \
            "<meta property=\"og:title\" content=\"Pages Site\" />\n" \
            "<meta property=\"og:image\" content=\"foo.png\" />\n" \
            "<meta property=\"og:url\" content=\"http://test.host\" />"
        )
      end
    end
  end
end
