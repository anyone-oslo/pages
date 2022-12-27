# frozen_string_literal: true

require "rails_helper"

describe PagePath do
  subject { build(:page_path) }

  it { is_expected.to belong_to(:page) }

  it { is_expected.to validate_presence_of(:locale) }
  it { is_expected.to validate_presence_of(:path) }
  it { is_expected.to validate_uniqueness_of(:path).scoped_to(:locale) }

  describe ".associate" do
    subject(:path) do
      described_class.associate(page, locale: "nb", path: "foo")
    end

    let(:page) { create(:blank_page) }

    context "when detecting locale/path" do
      subject(:path) { described_class.associate(page) }

      let(:page) { create(:page, locale: "nb", name: "Foobar") }

      it "reads the locale" do
        expect(path.locale).to eq("nb")
      end

      it "determines the path" do
        expect(path.path).to eq("foobar")
      end
    end

    context "when path doesn't exist" do
      it { is_expected.to be_a(described_class) }

      it "creates a new PagePath" do
        expect { path }.to change(described_class, :count).by(1)
      end
    end

    context "when path already exists" do
      before do
        create(:page_path, page: page, locale: "nb", path: "foo")
      end

      it { is_expected.to be_a(described_class) }

      it "does not create a new PagePath" do
        expect { path }.not_to change(described_class, :count)
      end

      it "changes the page" do
        expect(path.page).to eq(page)
      end
    end

    context "when page isn't saved" do
      let(:page) { build(:page) }

      it "raises an error" do
        expect { path }.to raise_error(PagePath::PageNotSavedError)
      end
    end
  end

  describe ".get" do
    subject { described_class.get("nb", "foo/bar") }

    context "when path exists" do
      let!(:path) { create(:page_path, locale: "nb", path: "foo/bar") }

      it { is_expected.to eq(path) }
    end

    context "when path doesn't exist" do
      it { is_expected.to be_nil }
    end
  end
end
