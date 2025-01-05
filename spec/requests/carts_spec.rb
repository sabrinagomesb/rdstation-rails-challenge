require 'rails_helper'

RSpec.describe "/carts", type: :request do
  pending "TODO: Escreva os testes de comportamento do controller de carrinho necessários para cobrir a sua implmentação #{__FILE__}"
  describe "POST /add_item" do
    let(:cart) { Cart.create }
    let(:product) { Product.create(name: "Test Product", price: 10.0) }
    let!(:cart_item) { CartItem.create(cart: cart, product: product, quantity: 1) }

    before do
      allow_any_instance_of(ApplicationController)
        .to receive(:session)
        .and_return({ cart_id: cart.id })
    end

    context 'when the product already is in the cart' do
      subject do
        patch '/cart/add_item', params: { product_id: product.id, quantity: 2 }, as: :json
      end

      it 'updates the quantity of the existing item to the new value (2)' do
        expect { subject }.to change { cart_item.reload.quantity }.by(1)
      end
    end
  end
end
