class Role < ActiveRecord::Base
  belongs_to :user
  validates :name, presence: true

  class << self
    def names
      all.map(&:name)
    end
  end
end