class CartSerializer < ActiveModel::Serializer
  def to_hash
    {
      id: object.id,
      products: object.cart_items.map do |item|
        {
          id: item.product.id,
          name: item.product.name,
          quantity: item.quantity,
          unit_price: item.product.price.to_f,
          total_price: (item.product.price * item.quantity).to_f
        }
      end,
      total_price: object.cart_items.sum(&:total_price).to_f
    }
  end

  def attributes(*_args)
    to_hash
  end
end
