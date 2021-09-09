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

  describe "#image_file_field" do
    let(:template) { spy }

    it "renders an image field" do
      builder.image_file_field(:image)
      expect(template).to have_received(:file_field)
        .with(:user, :image, object: resource)
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
          "<span class=\"error\">kan ikke være blank</span>"
        )
      end
    end
  end

  describe "#labelled_text_field" do
    let(:template) { spy }

    it "renders the field" do
      builder.labelled_text_field(:email, size: 20)
      expect(template).to have_received(:text_field)
        .with(:user, :email, object: resource, size: 20)
    end
  end

  describe "#labelled_text_area" do
    let(:template) { spy }

    it "renders the field" do
      builder.labelled_text_area(:email)
      expect(template).to have_received(:text_area)
        .with(:user, :email, object: resource)
    end
  end

  describe "#labelled_country_select" do
    it "renders the field" do
      allow(builder).to receive(:country_select)
      builder.labelled_country_select(:email)
      expect(builder).to have_received(:country_select)
        .with(:email, {}, {}, {})
    end
  end

  describe "#labelled_date_select" do
    let(:template) { spy }

    it "renders the field" do
      builder.labelled_date_select(:created_at)
      expect(template).to have_received(:date_select)
        .with(:user, :created_at, { object: resource }, {})
    end
  end

  describe "#labelled_datetime_select" do
    let(:template) { spy }

    it "renders the field" do
      builder.labelled_datetime_select(:created_at)
      expect(template).to have_received(:datetime_select)
        .with(:user, :created_at, { object: resource }, {})
    end
  end

  describe "#labelled_time_select" do
    let(:template) { spy }

    it "renders the field" do
      builder.labelled_time_select(:created_at)
      expect(template).to have_received(:time_select)
        .with(:user, :created_at, { object: resource }, {})
    end
  end

  describe "#labelled_select" do
    let(:template) { spy }
    let(:options) { %w[Foo Bar] }

    it "renders the field" do
      builder.labelled_select(:email, options)
      expect(template).to have_received(:select)
        .with(:user, :email, options, { object: resource }, {})
    end
  end

  describe "#labelled_check_box" do
    let(:template) { spy }

    it "renders the field" do
      builder.labelled_check_box(:activated)
      expect(template).to have_received(:check_box)
        .with(:user, :activated, { object: resource }, "1", "0")
    end
  end

  describe "#labelled_image_file_field" do
    let(:template) { spy }

    it "renders the field" do
      builder.labelled_image_file_field(:image)
      expect(template).to have_received(:file_field)
        .with(:user, :image, object: resource)
    end
  end

  describe "#labelled_password_field" do
    let(:template) { spy }

    it "renders the field" do
      builder.labelled_password_field(:email)
      expect(template).to have_received(:password_field)
        .with(:user, :email, object: resource)
    end
  end
end
