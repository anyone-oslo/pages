require "rails_helper"

RSpec.describe PagesCore::Admin::TagEditorHelper, type: :helper do
  describe "#tag_editor_for" do
    let!(:tag) { create(:tag) }
    let(:page) { create(:page).tap { |p| p.tags << tag } }
    let(:builder) { PagesCore::FormBuilder.new("page", page, helper, {}) }

    subject { helper.tag_editor_for(builder, page) }

    it "should render the tag editor" do
      expect(subject).to eq(
        "<div class=\"tag-editor clearfix\">" \
          "<input class=\"serialized_tags\" type=\"hidden\" " \
          "value=\"[&quot;#{tag.name}&quot;]\" " \
          "name=\"page[serialized_tags]\" id=\"page_serialized_tags\" />" \
          "<div class=\"tags\"><span class=\"tag\">" \
          "<input type=\"checkbox\" name=\"tag-#{tag.id}\" " \
          "id=\"tag-#{tag.id}\" " \
          "value=\"1\" checked=\"checked\" /><span class=\"name\">" \
          "#{tag.name}</span></span></div><div class=\"add-tag-form\">" \
          "<input type=\"text\" name=\"add_tag\" id=\"add_tag\" " \
          "value=\"Add tag...\" class=\"add-tag\" />" \
          "<button class=\"add-tag-button\">Add</button></div></div>"
      )
    end
  end
end
