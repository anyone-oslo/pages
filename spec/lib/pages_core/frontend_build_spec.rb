# frozen_string_literal: true

require "rails_helper"

RSpec.describe PagesCore::FrontendBuild do
  describe ".require!" do
    it "passes when the asset has been built" do
      expect { described_class.require!("pages_core/admin.css") }
        .not_to raise_error
    end

    it "raises an error when the asset is missing" do
      expect { described_class.require!("pages_core/missing.js") }
        .to raise_error(described_class::MissingBuildError, /pnpm build/)
    end
  end
end
