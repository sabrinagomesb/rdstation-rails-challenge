require 'rails_helper'

RSpec.describe CartItem, type: :model do
  describe 'associations' do
    it { should belong_to(:cart).touch(:last_interaction_at) }
    it { should belong_to(:product) }
  end

  describe 'validations' do
    it { should validate_presence_of(:quantity) }

    it 'validates quantity is a positive integer' do
      cart = create(:cart)
      product = create(:product)

      cart_item = build(:cart_item, cart: cart, product: product, quantity: 5)
      expect(cart_item).to be_valid

      cart_item = build(:cart_item, cart: cart, product: product, quantity: 5.5)
      expect(cart_item).not_to be_valid
      expect(cart_item.errors[:quantity]).to include('must be a positive integer')

      cart_item = build(:cart_item, cart: cart, product: product, quantity: -1)
      expect(cart_item).not_to be_valid
      expect(cart_item.errors[:quantity]).to include('must be a positive integer')

      cart_item = build(:cart_item, cart: cart, product: product, quantity: 0)
      expect(cart_item).not_to be_valid
      expect(cart_item.errors[:quantity]).to include('must be a positive integer')
    end
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
