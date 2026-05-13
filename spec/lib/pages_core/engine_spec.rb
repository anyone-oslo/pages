# frozen_string_literal: true

require "rails_helper"

describe PagesCore::Engine do
  describe "pages_core.sentry initializer" do
    subject(:initializer) do
      described_class.initializers.find { |i| i.name == "pages_core.sentry" }
    end

    it "is registered" do
      expect(initializer).not_to be_nil
    end

    it "runs after :load_config_initializers so Sentry.configuration is available" do
      expect(initializer.after).to eq(:load_config_initializers)
    end
  end
end
