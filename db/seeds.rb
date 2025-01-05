# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end


[
  { name: 'Samsung Galaxy S24 Ultra', price: 12999.99 },
  { name: 'iPhone 15 Pro Max', price: 14999.99 },
  { name: 'Xiamo Mi 27 Pro Plus Master Ultra', price: 999.99 },
  { name: 'iPad Pro 2023', price: 1999.99 },
  { name: 'Samsung Galaxy Tab S8', price: 1299.99 },
  { name: 'Xiamo Mi Pad 6', price: 499.99 },
  { name: 'Samsung Galaxy Watch 5', price: 599.99 },
  { name: 'Apple Watch 10', price: 799.99 },
].each do |product_data|
  Product.find_or_create_by(name: product_data[:name]) do |product|
    product.price = product_data[:price]
  end
end

