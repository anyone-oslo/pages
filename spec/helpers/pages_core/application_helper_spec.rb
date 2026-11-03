# frozen_string_literal: true

require "rails_helper"

RSpec.describe PagesCore::ApplicationHelper do
  describe "#safe_url" do
    it "allows http URLs" do
      expect(helper.safe_url("http://example.com")).to eq("http://example.com")
    end

    it "allows https URLs" do
      expect(helper.safe_url("https://example.com")).to eq("https://example.com")
    end

    it "allows mailto URLs" do
      expect(helper.safe_url("mailto:user@example.com")).to eq("mailto:user@example.com")
    end

    it "allows tel URLs" do
      expect(helper.safe_url("tel:+1234567890")).to eq("tel:+1234567890")
    end

    it "blocks data URLs" do
      expect(helper.safe_url("data:text/html,Hello")).to eq("#")
    end

    it "blocks uppercase data URLs" do
      expect(helper.safe_url("DATA:text/html,Hello")).to eq("#")
    end

    it "blocks javascript URLs" do
      expect(helper.safe_url("javascript:alert(1)")).to eq("#")
    end

    it "blocks vbscript URLs" do
      expect(helper.safe_url("vbscript:MsgBox(1)")).to eq("#")
    end

    it "allows relative paths" do
      expect(helper.safe_url("/about")).to eq("/about")
    end

    it "blocks protocol-relative URLs" do
      expect(helper.safe_url("//example.com/x")).to eq("#")
    end

    it "blocks paths starting with a slash and a backslash" do
      expect(helper.safe_url("/\\example.com/x")).to eq("#")
    end

    it "blocks protocol-relative URLs split by a tab" do
      expect(helper.safe_url("/\t/example.com")).to eq("#")
    end

    it "blocks protocol-relative URLs split by a newline" do
      expect(helper.safe_url("/\n/example.com")).to eq("#")
    end

    it "allows anchor links" do
      expect(helper.safe_url("#section")).to eq("#section")
    end

    it "returns '#' for blank input" do
      expect(helper.safe_url("")).to eq("#")
    end

    it "returns '#' for nil input" do
      expect(helper.safe_url(nil)).to eq("#")
    end

    it "returns '#' for invalid URIs" do
      expect(helper.safe_url("ht tp://bad url")).to eq("#")
    end
  end
end
