# frozen_string_literal: true

require "rails_helper"

RSpec.describe PagesCore::Templates::TemplateConfiguration do
  describe "#all_blocks" do
    subject { described_class.all_blocks }

    let(:blocks) do
      %i[name body headline excerpt boxout meta_title
         meta_description open_graph_title open_graph_description]
    end

    it { is_expected.to match(blocks) }
  end
end
