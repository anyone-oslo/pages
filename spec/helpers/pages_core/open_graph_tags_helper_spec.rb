# frozen_string_literal: true

require "rails_helper"

RSpec.describe PagesCore::OpenGraphTagsHelper, type: :helper do
  let(:page) do
    build(:page, open_graph_title: "Article", open_graph_description: "desc")
  end

  describe "#open_graph_tags" do
    subject(:tags) { helper.open_graph_tags }

    let(:pattern) do
      "<meta property=\"og:type\" content=\"website\">\n" \
        "<meta property=\"og:site_name\" content=\"Pages Site\">\n" \
        "<meta property=\"og:title\" content=\"Pages Site\">\n" \
        "<meta property=\"og:url\" content=\"http://test.host\">"
    end

    it { is_expected.to eq(pattern) }

    context "with a page" do
      let(:pattern) do
        "<meta property=\"og:type\" content=\"website\">\n" \
          "<meta property=\"og:site_name\" content=\"Pages Site\">\n" \
          "<meta property=\"og:title\" content=\"Article\">\n" \
          "<meta property=\"og:description\" content=\"desc\">\n" \
          "<meta property=\"og:url\" content=\"http://test.host\">"
      end

      before { helper.instance_variable_set(:@page, page) }

      it { is_expected.to eq(pattern) }
    end

    context "with an image" do
      let(:pattern) do
        "<meta property=\"og:type\" content=\"website\">\n" \
          "<meta property=\"og:site_name\" content=\"Pages Site\">\n" \
          "<meta property=\"og:title\" content=\"Pages Site\">\n" \
          "<meta property=\"og:image\" content=\"foo.png\">\n" \
          "<meta property=\"og:url\" content=\"http://test.host\">"
      end

      before { helper.meta_image "foo.png" }

      it { is_expected.to eq(pattern) }
    end
  end
end
