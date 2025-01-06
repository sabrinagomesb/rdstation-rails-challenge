FactoryBot.define do
  factory :cart_item do
    cart
    product
    quantity { 1 }

    trait :with_product do
      product { create(:product) }
    end

    trait :with_cart do
      cart { create(:cart) }
    end
  end
end
