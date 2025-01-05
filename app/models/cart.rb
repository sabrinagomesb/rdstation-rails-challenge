class Cart < ApplicationRecord
  has_many :cart_items, dependent: :destroy
  has_many :products, through: :cart_items

  validates :total_price, numericality: { greater_than_or_equal_to: 0 }

  # TODO: lógica para marcar o carrinho como abandonado e remover se abandonado

  enum :status, {
    open: 'open',
    abndoned: 'abandoned',
  }, default: 'open'

  before_validation :set_default_total_price, on: :create

  private

  def set_default_total_price
    self.total_price ||= 0
  end

end
