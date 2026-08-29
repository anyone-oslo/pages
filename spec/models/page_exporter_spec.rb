# frozen_string_literal: true

require "rails_helper"

describe PageExporter do
  let(:base_dir) { Pathname.new(Dir.mktmpdir) }
  let(:page) { create(:page) }

  after { FileUtils.remove_entry(base_dir) }

  def export
    described_class.new(base_dir).export
  end

  def exported(dir)
    Dir.glob(base_dir.join("**", dir, "*")).map { |path| Pathname.new(path) }
  end

  describe "attachments" do
    let!(:attachment) { create(:page_file, page:).attachment }

    it "exports one file per attachment" do
      export
      expect(exported("attachments").length).to eq(1)
    end

    it "names the file after the content hash and filename" do
      export
      expect(exported("attachments").first.basename.to_s)
        .to eq("#{attachment.content_hash}-#{attachment.filename}")
    end

    it "writes the data" do
      export
      expect(exported("attachments").first.binread).to eq(attachment.data)
    end
  end

  describe "images" do
    let!(:page_image) do
      PageImage.create!(page:, image: create(:image), locale: page.locale)
    end

    it "exports one file per image" do
      export
      expect(exported("images").length).to eq(1)
    end

    it "names the file after the content hash and filename" do
      export
      expect(exported("images").first.basename.to_s)
        .to eq("#{page_image.image.content_hash}-#{page_image.image.filename}")
    end

    it "writes the data" do
      export
      expect(exported("images").first.binread).to eq(page_image.image.data)
    end
  end
end
