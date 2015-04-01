require "spec_helper"

describe InviteRole do
  it { is_expected.to belong_to(:invite) }

  it { is_expected.to validate_presence_of(:name) }

  it { is_expected.to allow_value("users").for(:name) }
  it { is_expected.not_to allow_value("notarole").for(:name) }

  describe "#to_s" do
    subject { role.to_s }
    let(:role) { InviteRole.new(name: "foo") }
    it { is_expected.to eq("Foo") }
  end
end
