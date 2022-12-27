# frozen_string_literal: true

require "rails_helper"

describe Tag do
  it { is_expected.to have_many(:taggings) }

  describe ".tags_and_suggestions_for" do
    subject { described_class.tags_and_suggestions_for(taggable) }

    let!(:tag) { create(:tag) }
    let(:taggable) { create(:page) }

    context "when nothing has been tagged" do
      it { is_expected.to match_array([]) }
    end

    context "when subject has been tagged" do
      before { taggable.tag_with!(tag) }

      it { is_expected.to match_array([tag]) }
    end

    context "when subject has been tagged and another tagging exists" do
      let(:other_tag) { create(:tag) }
      let(:other_taggable) { create(:page) }

      before do
        other_taggable.tag_with!(other_tag)
        taggable.tag_with!(tag)
      end

      it { is_expected.to match_array([tag, other_tag]) }
    end

    context "when a pinned tag exists" do
      let!(:pinned_tag) { create(:tag, pinned: true) }
      let(:other_tag) { create(:tag) }
      let(:other_taggable) { create(:page) }

      before do
        other_taggable.tag_with!(other_tag)
        taggable.tag_with!(tag)
      end

      it { is_expected.to match_array([tag, pinned_tag, other_tag]) }
    end
  end
end
