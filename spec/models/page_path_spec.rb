# encoding: utf-8

require "rails_helper"

describe PagePath do
  subject { build(:page_path) }

  it { is_expected.to belong_to(:page) }

  it { is_expected.to validate_presence_of(:locale) }
  it { is_expected.to validate_presence_of(:path) }
  it { is_expected.to validate_uniqueness_of(:path).scoped_to(:locale) }

  describe ".associate" do
    let(:page) { create(:blank_page) }
    subject { PagePath.associate(page, locale: "nb", path: "foo") }

    context "when detecting locale/path" do
      let(:page) { create(:page, locale: "nb", name: "Foobar") }
      subject { PagePath.associate(page) }

      it "should get the locale/path from the page" do
        expect(subject.locale).to eq("nb")
        expect(subject.path).to eq("foobar")
     end
    end

    context "when path doesn't exist" do
      it { is_expected.to be_a(PagePath) }
      it "should create a new PagePath" do
        expect { subject }.to change { PagePath.count }.by(1)
      end
    end

    context "when path already exists" do
      let(:other_page) { create(:page) }
      let!(:path) { create(:page_path, page: page, locale: "nb", path: "foo") }

      it { is_expected.to be_a(PagePath) }

      it "shouldn't create a new PagePath" do
        expect { subject }.to change { PagePath.count }.by(0)
      end

      it "should change the page" do
        expect(subject.page).to eq(page)
      end
    end

    context "when page isn't saved" do
      let(:page) { build(:page) }

      it "should raise an error" do
        expect { subject }.to raise_error(PagePath::PageNotSavedError)
      end
    end
  end

  describe ".get" do
    subject { PagePath.get("nb", "foo/bar") }

    context "when path exists" do
      let!(:path) { create(:page_path, locale: "nb", path: "foo/bar") }

      it { is_expected.to eq(path) }
    end

    context "when path doesn't exist" do
      it { is_expected.to eq(nil) }
    end
  end
end
