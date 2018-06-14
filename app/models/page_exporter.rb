require "fileutils"

class PageExporter
  attr_reader :base_dir

  def initialize(base_dir)
    @base_dir = base_dir
  end

  def export
    Page.roots.in_locale(I18n.default_locale).each { |p| export_page(p) }
    puts
  end

  private

  def export_page(page)
    print "."
    export_page_contents(page)
    export_images(page)
    export_files(page)
    page.subpages.in_locale(I18n.default_locale).each { |p| export_page(p) }
  end

  def export_files(page)
    path = page_path(page).join("files")
    page.page_files.each do |file|
      write_file(
        path.join([file.content_hash, file.filename].join("-")),
        file.data
      )
    end
  end

  def export_images(page)
    path = page_path(page).join("images")
    page.page_images.each do |pi|
      write_file(
        path.join([pi.image.content_hash, pi.image.filename].join("-")),
        pi.image.data
      )
    end
  end

  def export_page_contents(page)
    path = page_path(page)
    page.locales.map { |l| page.localize(l) }.each do |p|
      json = PageExportSerializer.new(p).to_json
      basename = path.join("#{page_file_name(p)}.#{p.locale}")
      write_file(path.join("page.#{p.locale}.json"), json)
      write_file(path.join("page.#{p.locale}.yml"), JSON.parse(json).to_yaml)
      write_file(path.join("page.#{p.locale}.txt"), text_page(p))
    end
  end

  def page_path(page)
    base_dir.join(page.self_and_ancestors
                      .reverse
                      .map { |p| page_path_segment(p) }.join("/pages/"))
  end

  def page_file_name(page)
    [page.path_segment,
     page.to_param[0..250]].reject(&:blank?).first
  end

  def page_path_segment(page)
    prefix = page.deleted? ? "_deleted/" : ""
    if page&.parent&.news_page?
      prefix += "[#{page.published_at.to_date.iso8601}] "
    end
    prefix + page_file_name(page)
  end

  def text_page(page)
    PagesCore::Templates::TemplateConfiguration
      .all_blocks
      .select { |attr| page.send("#{attr}?".to_sym) }
      .map { |attr| ["-- #{attr}: --", page.send(attr).strip].join("\n\n") }
      .join("\n\n\n")
  end

  def write_file(path, data)
    FileUtils.mkdir_p(File.dirname(path))
    File.open(path, "wb") { |fh| fh.write(data) }
  end
end
