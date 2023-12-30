# frozen_string_literal: true

require "rails_helper"

RSpec.describe "PagesController routing" do
  let(:locale) { "nb" }
  let(:page) { create(:page) }
  let(:expected_route) do
    { controller: "pages",
      action: "show",
      locale:,
      path: "foo/bar" }
  end

  it "routes standard page URLs" do
    expect(get: "/nb/pages/12-My-page").to(
      route_to(controller: "pages", action: "show",
               locale: "nb", id: "12-My-page")
    )
  end

  context "with locale" do
    let(:path) { "/nb/foo/bar" }

    context "when path doesn't exist" do
      it "does not recognize the route" do
        expect(get: path).not_to route_to(expected_route)
      end
    end

    context "when path exists" do
      before do
        create(:page_path, page:, locale: "nb", path: "foo/bar")
      end

      it "recognizes the route" do
        expect(get: path).to route_to(expected_route)
      end
    end
  end

  context "without locale" do
    let(:locale) { I18n.default_locale.to_s }
    let(:path) { "/foo/bar" }

    context "when path doesn't exist" do
      it "does not recognize the route" do
        expect(get: path).not_to route_to(expected_route)
      end
    end

    context "when path exists" do
      before do
        create(:page_path, page:, locale:, path: "foo/bar")
      end

      it "recognizes the route" do
        expect(get: path).to route_to(expected_route)
      end
    end
  end
end
