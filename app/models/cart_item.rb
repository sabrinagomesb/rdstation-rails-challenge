# frozen_string_literal: true

class CartItem < ApplicationRecord
  belongs_to :cart, touch: :last_interaction_at
  belongs_to :product

  validates :quantity,
    presence: { message: 'can\'t be blank' },
    numericality: {
      greater_than: 0,
      only_integer: true,
      message: 'must be a positive integer'
    }

  def total_price
    product.price * quantity
  end
end
