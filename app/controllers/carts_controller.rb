class CartsController < ApplicationController
  before_action :set_cart
  before_action :set_product, only: %i[create add]

  def show
    render json: @cart, include: :products
  end

  def create
    product = Product.find(params[:product_id])
    quantity = params[:quantity].to_i

    cart_item = @cart.cart_items.find_or_initialize_by(product: product)
    cart_item.quantity += quantity
    cart_item.save!

    update_cart_total_price

    render json: @cart, include: :products
  end

  def add
    product = Product.find(params[:product_id])
    quantity = params[:quantity].to_i

    cart_item = @cart.cart_items.find_or_initialize_by(product: product)
    cart_item.quantity += quantity
    cart_item.save!

    update_cart_total_price

    render json: @cart, include: :products
  end

  private

  def set_cart
    @cart = Cart.find_or_create_by(id: session[:cart_id])
    session[:cart_id] = @cart.id
  end

  def set_product
    @product = Product.find(params[:product_id])
  end

  def update_cart_total_price
    @cart.total_price = @cart.cart_items.sum(&:total_price)
    @cart.save!
  end
end
