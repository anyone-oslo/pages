# frozen_string_literal: true

require "rails_helper"

describe PagesCore::FormBuilder do
  let(:template) { self }
  let(:resource) { build(:user) }
  let(:builder) { described_class.new(:user, resource, template, {}) }

  around do |example|
    I18n.with_locale(:nb) do
      example.run
    end
  end

  describe "#field_with_label" do
    subject(:field) { builder.field_with_label(:email, "content") }

    it "renders the field" do
      expect(field).to eq(
        "<div class=\"field\"><label for=\"user_email\">Email</label>" \
        "content</div>"
      )
    end

    context "when field has errors" do
      let(:resource) { User.new.tap(&:validate) }

      it { is_expected.to match("class=\"field field-with-errors\"") }
    end
  end

  describe "#label_for" do
    subject(:label) { builder.label_for(:email) }

    it { is_expected.to eq("<label for=\"user_email\">Email</label>") }

    context "with a label" do
      subject { builder.label_for(:email, "Foo") }

      it { is_expected.to eq("<label for=\"user_email\">Foo</label>") }
    end

    context "with errors" do
      let(:resource) { User.new.tap(&:validate) }

      it "outputs the error" do
        expect(label).to match(
          "<span class=\"error\">kan ikke være tom</span>"
        )
      end
    end
  end
end
