class LocalizeImages < ActiveRecord::Migration
  def locale
    I18n.default_locale
  end

  def up
    Image.all.in_locale(locale).each do |image|
      unless image.attributes["byline"].blank?
        Localization.create(
          localizable: image,
          name: "caption",
          locale: locale,
          value: image.attributes["byline"]
        )
      end
    end
    remove_column :images, :name, :string
    remove_column :images, :byline, :string
    remove_column :images, :description, :string
  end

  def down
    add_column :images, :name, :string
    add_column :images, :byline, :string
    add_column :images, :description, :string

    Localization.where(
      localizable_type: "Image",
      name: "caption",
      locale: locale
    ).each do |localization|
      localization.localizable.update_column(
        "byline",
        localization.value
      )
      localization.destroy
    end
  end
end
