class Cart < ApplicationRecord
  has_many :cart_items, dependent: :destroy
  has_many :products, through: :cart_items

  validates :total_price, numericality: { greater_than_or_equal_to: 0 }

  enum :status, {
    open: 'open',
    abandoned: 'abandoned',
  }, default: 'open'

  before_validation :set_default_total_price, on: :create

  def mark_as_abandoned
    return if abandoned?
    if last_interaction_at <= 3.hours.ago
      update!(status: :abandoned)
    end
  end

  def remove_if_abandoned
    if abandoned? && last_interaction_at <= 7.days.ago
      destroy
    end
  end

  private

  def set_default_total_price
    self.total_price ||= 0
  end

end
