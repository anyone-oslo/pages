require "rails_helper"

RSpec.describe PagesCore::PubSub do
  let(:subscriber) { described_class.subscribe(:foo) {} }

  describe "#publish" do
    it "calls the subscribers" do
      foo = 1
      described_class.subscribe(:update_foo) { |payload| foo = payload.value }
      described_class.publish(:update_foo, value: 5)
      expect(foo).to eq(5)
    end
  end

  describe "#subscribe" do
    it "registers the subscriber" do
      expect(described_class.subscribers).to include(subscriber)
    end
  end

  describe "#unsubscribe" do
    it "removes the subscriber" do
      described_class.unsubscribe(subscriber)
      expect(described_class.subscribers).not_to include(subscriber)
    end
  end
end
