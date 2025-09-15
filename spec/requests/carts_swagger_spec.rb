require 'swagger_helper'

RSpec.describe 'Carts API', type: :request do
  path '/cart' do
    get 'Get current cart' do
      tags 'Cart'
      produces 'application/json'

      response '200', 'cart found' do
        schema type: :object,
               properties: {
                 id: { type: :integer },
                 products: {
                   type: :array,
                   items: {
                     type: :object,
                     properties: {
                       id: { type: :integer },
                       name: { type: :string },
                       quantity: { type: :integer },
                       unit_price: { type: :number },
                       total_price: { type: :number }
                     }
                   }
                 },
                 total_price: { type: :number }
               }

        let!(:cart) { create(:cart) }
        let!(:product) { create(:product, name: 'Test Product', price: 10.99) }
        let!(:cart_item) { create(:cart_item, cart: cart, product: product, quantity: 2) }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['id']).to be_present
          expect(data['products']).to be_an(Array)
          expect(data['total_price']).to be_a(Numeric)
        end
      end
    end

    post 'Add product to cart' do
      tags 'Cart'
      consumes 'application/json'
      produces 'application/json'

      parameter name: :cart, in: :body, schema: {
        type: :object,
        properties: {
          product_id: { type: :integer },
          quantity: { type: :integer }
        },
        required: ['product_id', 'quantity']
      }

      response '201', 'product added to cart' do
        schema type: :object,
               properties: {
                 id: { type: :integer },
                 products: {
                   type: :array,
                   items: {
                     type: :object,
                     properties: {
                       id: { type: :integer },
                       name: { type: :string },
                       quantity: { type: :integer },
                       unit_price: { type: :number },
                       total_price: { type: :number }
                     }
                   }
                 },
                 total_price: { type: :number }
               }

        let!(:product) { create(:product, name: 'Test Product', price: 10.99) }
        let(:cart) { { product_id: product.id, quantity: 2 } }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['id']).to be_present
          expect(data['products']).to be_an(Array)
          expect(data['total_price']).to be_a(Numeric)
        end
      end

      response '422', 'invalid parameters' do
        schema type: :object,
               properties: {
                 error: { type: :string }
               }

        let(:cart) { { product_id: 999999, quantity: 1 } }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(response.status).to eq(422)
        end
      end

      response '422', 'decimal quantity not allowed' do
        schema type: :object,
               properties: {
                 error: { type: :string }
               }

        let!(:product) { create(:product, name: 'Test Product', price: 10.99) }
        let(:cart) { { product_id: product.id, quantity: 6.7 } }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(response.status).to eq(422)
          expect(data['error']).to eq('Validation failed: Quantity must be a positive integer')
        end
      end
    end
  end

  path '/cart/add_item' do
    patch 'Update product quantity in cart' do
      tags 'Cart'
      consumes 'application/json'
      produces 'application/json'

      parameter name: :cart, in: :body, schema: {
        type: :object,
        properties: {
          product_id: { type: :integer },
          quantity: { type: :integer }
        },
        required: ['product_id', 'quantity']
      }

      response '200', 'product quantity updated' do
        schema type: :object,
               properties: {
                 id: { type: :integer },
                 products: {
                   type: :array,
                   items: {
                     type: :object,
                     properties: {
                       id: { type: :integer },
                       name: { type: :string },
                       quantity: { type: :integer },
                       unit_price: { type: :number },
                       total_price: { type: :number }
                     }
                   }
                 },
                 total_price: { type: :number }
               }

        let!(:product) { create(:product, name: 'Test Product', price: 10.99) }
        let(:cart) { { product_id: product.id, quantity: 3 } }

        before do
          post '/cart', params: { product_id: product.id, quantity: 1 }
        end

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['id']).to be_present
          expect(data['products']).to be_an(Array)
          expect(data['total_price']).to be_a(Numeric)
        end
      end

      response '422', 'invalid parameters' do
        schema type: :object,
               properties: {
                 error: { type: :string }
               }

        let!(:cart) { create(:cart) }
        let(:cart_params) { { product_id: 999999, quantity: 1 } }

        run_test! do |response|
          expect(response.status).to eq(422)
        end
      end

      response '422', 'decimal quantity not allowed' do
        schema type: :object,
               properties: {
                 error: { type: :string }
               }

        let!(:product) { create(:product, name: 'Test Product', price: 10.99) }
        let(:cart) { { product_id: product.id, quantity: 5.5 } }

        before do
          post '/cart', params: { product_id: product.id, quantity: 1 }
        end

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(response.status).to eq(422)
          expect(data['error']).to eq('Validation failed: Quantity must be a positive integer')
        end
      end
    end
  end

  path '/cart/{product_id}' do
    delete 'Remove product from cart' do
      tags 'Cart'
      produces 'application/json'

      parameter name: :product_id, in: :path, type: :integer

      response '200', 'product removed from cart' do
        schema type: :object,
               properties: {
                 id: { type: :integer },
                 products: {
                   type: :array,
                   items: {
                     type: :object,
                     properties: {
                       id: { type: :integer },
                       name: { type: :string },
                       quantity: { type: :integer },
                       unit_price: { type: :number },
                       total_price: { type: :number }
                     }
                   }
                 },
                 total_price: { type: :number }
               }

        let!(:product) { create(:product, name: 'Test Product', price: 10.99) }
        let(:product_id) { product.id }

        before do
          post '/cart', params: { product_id: product.id, quantity: 2 }
        end

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['id']).to be_present
          expect(data['products']).to be_an(Array)
          expect(data['total_price']).to be_a(Numeric)
        end
      end

      response '404', 'product not found in cart' do
        schema type: :object,
               properties: {
                 error: { type: :string }
               }

        let!(:cart) { create(:cart) }
        let(:product_id) { 999999 }

        run_test! do |response|
          expect(response.status).to eq(404)
        end
      end
    end
  end
end
