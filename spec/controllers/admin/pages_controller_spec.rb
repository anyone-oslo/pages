require "rails_helper"

describe Admin::PagesController, type: :controller do
  let(:locale) { I18n.default_locale }
  let(:page) { create(:page) }

  before { login }

  describe "PUT move" do
    let(:parent) { create(:page) }
    let!(:other) { create(:page, parent: parent, position: 1) }

    before do
      put :move, id: page.id, locale: locale, parent_id: parent.id, position: 1
      page.reload
      other.reload
    end

    it { is_expected.to redirect_to(admin_pages_url(locale)) }

    it "should change the parent" do
      expect(page.parent).to eq(parent)
    end

    it "should change the positions" do
      expect(page.position).to eq(1)
      expect(other.position).to eq(2)
    end
  end
end
