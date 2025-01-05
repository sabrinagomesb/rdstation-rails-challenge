# spec/requests/carts_spec.rb
require 'rails_helper'

RSpec.describe "/carts", type: :request do

  let(:cart)    { Cart.create }
  let(:product) { Product.create(name: "Test Product", price: 10.0) }

  before do
    allow_any_instance_of(ApplicationController)
      .to receive(:session).and_return({ cart_id: cart.id })
  end

  describe "POST /cart" do
    context "when creating a new cart_item" do
      subject do
        post '/cart', params: { product_id: product.id, quantity: 3 }, as: :json
      end

      it "creates a cart_item in the cart" do
        expect { subject }.to change { cart.cart_items.count }.by(1)
      end

      it "sets the quantity to the provided value" do
        subject
        expect(cart.cart_items.last.quantity).to eq(3)
      end

      it "returns status :created" do
        subject
        expect(response).to have_http_status(:created)
      end
    end

    context "when the cart_item already exists" do
      let!(:existing_item) { CartItem.create(cart: cart, product: product, quantity: 2) }

      subject do
        post '/cart', params: { product_id: product.id, quantity: 5 }, as: :json
      end

      it "does not create a new cart_item, but updates the existing one" do
        expect { subject }.not_to change { cart.cart_items.count }
      end

      it "overwrites the quantity" do
        subject
        expect(existing_item.reload.quantity).to eq(5)
      end
    end
  end

  describe "GET /cart" do
    subject { get '/cart', as: :json }

    context "when the cart is empty" do
      it "returns a cart with 0 items" do
        subject
        json = JSON.parse(response.body)
        expect(json["products"]).to eq([]).or be_nil
      end
    end

    context "when the cart has items" do
      let!(:cart_item) { CartItem.create(cart: cart, product: product, quantity: 2) }

      it "returns the cart with items" do
        subject
        json = JSON.parse(response.body)
        expect(json["products"].size).to eq(1)
        expect(json["products"][0]["quantity"]).to eq(2)
      end
    end
  end

  describe "PATCH /cart/add_item" do
    let!(:cart_item) { CartItem.create(cart: cart, product: product, quantity: 1) }

    subject do
      patch '/cart/add_item', params: { product_id: product.id, quantity: 2 }, as: :json
    end

    it 'updates the quantity of the existing item to 2' do
      expect { subject }.to change { cart_item.reload.quantity }.from(1).to(2)
    end
  end

  describe "DELETE /cart/:product_id" do
    let(:product_2) { Product.create(name: "Other product", price: 5.0) }
    let!(:cart_item_1) { CartItem.create(cart: cart, product: product,   quantity: 1) }
    let!(:cart_item_2) { CartItem.create(cart: cart, product: product_2, quantity: 2) }

    context "when the product is in the cart" do
      subject { delete "/cart/#{product_2.id}", as: :json }

      it "removes the product from the cart" do
        expect { subject }.to change { cart.cart_items.count }.by(-1)
      end

      it "returns the updated cart" do
        subject
        json = JSON.parse(response.body)
        expect(json["products"].size).to eq(1)
        expect(json["products"][0]["id"]).to eq(product.id)
      end
    end

    context "when the product is NOT in the cart" do
      subject { delete "/cart/9999", as: :json }

      it "returns an error message" do
        subject
        expect(response).to have_http_status(:not_found)
        json = JSON.parse(response.body)
        expect(json["error"]).to eq("Product not in cart")
      end
    end
  end
end
