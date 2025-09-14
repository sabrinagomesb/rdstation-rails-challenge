require 'swagger_helper'

RSpec.describe 'Products API', type: :request do
  path '/products' do
    get 'List all products' do
      tags 'Products'
      produces 'application/json'

      response '200', 'products found' do
        schema type: :array,
               items: {
                 type: :object,
                 properties: {
                   id: { type: :integer },
                   name: { type: :string },
                   price: { type: :string },
                   created_at: { type: :string },
                   updated_at: { type: :string }
                 }
               }

        let!(:product1) { create(:product, name: 'Product 1', price: 10.99) }
        let!(:product2) { create(:product, name: 'Product 2', price: 20.50) }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data).to be_an(Array)
          expect(data.length).to eq(2)
        end
      end
    end
  end
end
