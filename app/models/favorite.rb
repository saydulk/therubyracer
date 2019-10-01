class Favorite < ActiveRecord::Base
  belongs_to :member

  validates_uniqueness_of :priority, scope: :member_id
  validates :priority, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true

  default_scope -> { order("priority asc") }

  before_create :set_priority, if: 'priority.blank?'

  private

  def set_priority
    self.priority = member.favorites.count + 1
  end
end
