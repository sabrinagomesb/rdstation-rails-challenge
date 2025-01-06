# frozen_string_literal: true

class CartItem < ApplicationRecord
  belongs_to :cart, touch: :last_interaction_at
  belongs_to :product

  validates :quantity, numericality: { greater_than: 0 }

  def total_price
    product.price * quantity
  end
end
