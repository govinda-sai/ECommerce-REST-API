# frozen_string_literal: true

class OrdersController < ApplicationController # rubocop:disable Style/Documentation
  before_action :set_order, only: %i[show update destroy]
  before_action :authenticate_user

  def index
    @orders = Order.all.map do |order|
      {
        order_id: order.id,
        user_name: order.user&.first_name, item_name: order.item.title,
        quantity: order.quantity, total_price: order.total_price
      }
    end
    render json: @orders
  end

  def show
    render json: { item_name: @order.item.title, category: @order.category.category_code, quantity: @order.quantity,
                   total_price: @order.total_price }
  end

  def create # rubocop:disable Metrics/MethodLength,Metrics/AbcSize,Metrics/PerceivedComplexity
    @order = Order.new(order_params)
    puts '#################################################'
    puts @order.user_id
    puts '#################################################'
    puts User.exists?
    if User.exists?(id: @order.user_id)
      if Item.exists?(id: @order.item_id)
        if @order.quantity.present?
          if @order.quantity.positive? # rubocop:disable Metrics/BlockNesting
            if @order.save # rubocop:disable Metrics/BlockNesting
              render json: @order, status: :created
            else
              render json: { message: 'order couldn\'t be created', errors: @order.errors.full_messages },
                     status: :unprocessable_entity
            end
          else
            render json: { message: 'quantity must be greater than 0' }, status: :unprocessable_entity
          end
        else
          render json: { message: 'quantity must be present' }, status: :unprocessable_entity
        end
      else
        render json: { message: 'invalid item' }, status: :unprocessable_entity
      end
    else
      render json: { message: 'invalid user' }, status: :unprocessable_entity
    end
  end

  def update
    if @order.update(order_params)
      render json: @order
    else
      render json: { message: 'item couldn\'t be updated' }, status: :unprocessable_entity
    end
  end

  def destroy
    return unless @order.destroy

    render json: { message: 'order deleted successfully' }, status: :ok
  end

  def orders_by_user
    user = User.find_by(id: params[:user_id])

    if user
      @orders_by_user = Order.where(user_id: user.id)
      render json: @orders_by_user, status: :ok
    else
      render json: { message: 'user not found' }, status: :not_found
    end
  end

  private

  def set_order
    @order = Order.find(params[:id])
  rescue Mongoid::Errors::DocumentNotFound
    render json: { message: 'order not found' }, status: :not_found
  end

  def order_params
    params.require(:order).permit(:user_id, :item_id, :category_id, :quantity, :total_price)
  end

  # authentication

  def authenticate_user
    token = request.headers['authorization']
    user = User.find_by(authentication_token: token)

    return if user

    render json: { error: 'Unauthorized' }, status: :unauthorized
  end
end
