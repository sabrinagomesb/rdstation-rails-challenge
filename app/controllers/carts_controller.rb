class CartsController < ApplicationController
  before_action :set_cart
  before_action :set_product, only: %i[create add_item]

  def show
    render json: @cart, include: :products
  end

  # POST /cart
  def create
    quantity = params[:quantity]

    cart_item = @cart.cart_items.find_or_initialize_by(product: @product)
    cart_item.quantity = quantity
    cart_item.save!

    update_cart_total_price

    render json: @cart, status: :created
  end

  # PATCH /cart/add
  def add_item
    new_quantity = (params[:quantity] || 1)

    item = @cart.cart_items.find_by(product: @product)
    return render_error('Product not in cart', :not_found) unless item

    item.update!(quantity: new_quantity)

    update_cart_total_price
    render json: @cart
  end

  def destroy_item
    cart_item = @cart.cart_items.find_by(product_id: params[:product_id])
    return render_error('Product not in cart', :not_found) unless cart_item

    cart_item.destroy
    update_cart_total_price

    render json: @cart
  end

  private

  def set_cart
    if session[:cart_id]
      @cart = Cart.find_by(id: session[:cart_id])
      unless @cart
        @cart = Cart.create!
        session[:cart_id] = @cart.id
      end
    else
      @cart = Cart.create!
      session[:cart_id] = @cart.id
    end
  end

  def set_product
    @product = Product.find(params[:product_id])
  end

  def update_cart_total_price
    @cart.total_price = @cart.cart_items.sum(&:total_price)
    @cart.save!
  end
end
