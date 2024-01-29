# frozen_string_literal: true

class ItemsController < ApplicationController # rubocop:disable Style/Documentation
  before_action :set_item, only: %i[show update destroy]

  def index
    @items = Item.all.map do |item|
      {
        item_id: item.id, product_title: item.title, category: item.category.category_code,
        product_description: item.description, product_price: item.price
      }
    end
    render json: @items
  end

  def show
    return unless @item

    render json: {
      product_title: @item.title, category: @item.category.category_code, product_description: @item.description, product_price: @item.price # rubocop:disable Layout/LineLength
    }
  end

  def create # rubocop:disable Metrics/MethodLength,Metrics/PerceivedComplexity,Metrics/AbcSize,Metrics/CyclomaticComplexity
    @item = Item.new(item_params)
    if @item.title.present?
      if Item.exists?(title: @item.title)
        render json: { message: 'item exists' }, status: :unprocessable_entity
      elsif @item.description.present?
        if Category.exists?(category_id: @item.category_id)
          if @item.price.present? # rubocop:disable Metrics/BlockNesting
            if @item.price.positive? # rubocop:disable Metrics/BlockNesting
              if @item.save # rubocop:disable Metrics/BlockNesting
                render json: @item, status: :created
              else
                render json: { message: 'item couldn\'t be created', errors: @item.errors.full_messages }, status: :unprocessable_entity
              end
            else
              render json: { message: 'price should be greater than 0' }, status: :unprocessable_entity
            end
          else
            render json: { message: 'price cannot be empty' }, status: :unprocessable_entity
          end
        else
          render json: { message: 'invalid category' }, status: :unprocessable_entity
        end
      else
        render json: { message: 'description cannot be empty' }, status: :unprocessable_entity
      end
    else
      render json: { message: 'title cannot be empty' }, status: :unprocessable_entity
    end
  end

  def update
    if @item.update(item_params)
      render json: @item
    else
      render json: { message: 'item couldn\'t be updated' }, status: :unprocessable_entity
    end
  end

  def destroy
    return unless @item.destroy

    render json: { message: 'item deleted successfully' }
  end

  def find_by_title
    puts '---------------------------------------'
    @items = Item.find_by(title: params[:title])
    puts "ITEMS BY TITLE - #{@items}"
    if @items
      render json: @items
    else
      render json: { message: 'no itmes present for the title' }, status: :not_found
    end
  rescue Mongoid::Errors::DocumentNotFound
    render json: { message: 'title not found' }, status: :not_found
  end

  def find_by_category
    @items = Item.find_by(category_id: params[:category_code])
    if @items
      render json: @items
    else
      render json: { message: 'no items for the category' }, status: :not_found
    end
  rescue Mongoid::Errors::DocumentNotFound
    render json: { message: 'category not found' }, status: :not_found
  end

  private

  def set_item
    @item = Item.find(params[:id])
  rescue Mongoid::Errors::DocumentNotFound
    render json: { message: 'item not found' }, status: :not_found
  end

  def item_params
    params.require(:item).permit(:title, :description, :price, :category_id)
  end
end
