require 'rails_helper'

RSpec.describe CartItem, type: :model do
  describe 'associations' do
    it { should belong_to(:cart).touch(:last_interaction_at) }
    it { should belong_to(:product) }
  end

  describe 'validations' do
    it { should validate_numericality_of(:quantity).is_greater_than(0) }
  end

  describe '#total_price' do
    it 'returns the product price multiplied by the quantity' do
      product = create(:product, price: 15.5)
      cart = create(:cart)
      cart_item = create(:cart_item, product: product, quantity: 3, cart: cart)

    expect(cart_item.total_price).to eq(46.5)
    end
  end
end
