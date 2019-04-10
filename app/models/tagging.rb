class Tagging < ActiveRecord::Base
  belongs_to :tag
  belongs_to :taggable, polymorphic: true, touch: true

  validates :taggable_id, presence: true
  validates :taggable_type, presence: true
  validates :tag_id,
            presence: true,
            uniqueness: { scope: %i[taggable_type taggable_id] }

  def self.tagged_class(taggable)
    ActiveRecord::Base.send(
      :class_of_active_record_descendant,
      taggable.class
    ).to_s
  end

  def self.find_taggable(tagged_class, tagged_id)
    tagged_class.constantize.find(tagged_id)
  end
end
