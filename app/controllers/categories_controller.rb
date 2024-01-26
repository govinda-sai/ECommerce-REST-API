# frozen_string_literal: true

require '/home/govindasai/ECommerceAPI/app/modules/read'

class CategoriesController < ApplicationController # rubocop:disable Style/Documentation
  before_action :set_category, only: %i[show update destroy]
  include Read

  def index
    @categories = Category.all.map do |category|
      {
        category_id: category.id, category_code: category.category_code, category_description: category.category_description # rubocop:disable Layout/LineLength
      }
    end
    render json: @categories
  end

  def show
    return unless @category

    render json: {
      category_code: @category.category_code, category_description: @category.category_description
    }
  end

  def create # rubocop:disable Metrics/MethodLength
    @category = Category.new(category_params)
    if @category.category_code.present?
      if @category.category_description.present?
        if Category.exists?(category_code: @category.category_code)
          render json: { message: 'category code exists' }, status: :unprocessable_entity
        elsif @category.save
          render json: @category, status: :created, location: @category
        else
          render json: { message: 'category couldn\'t be created' }, status: :unprocessable_entity
        end
      else
        render json: { message: 'category description cannot be null' }, status: :unprocessable_entity
      end
    else
      render json: { message: 'category code cannot be null' }, status: :unprocessable_entity
    end
  end

  def update
    if @category.update(category_params)
      render json: { message: 'category updated successfully', updated_category: @category }, status: :ok
    else
      render json: { message: 'category couldn\'t be updated' }, status: :unprocessable_entity
    end
  end

  def destroy
    return unless @category.destroy

    render json: { message: 'category deleted successfully' }, status: :ok
  end

  private

  def set_category
    @category = Category.find(params[:id])
  rescue Mongoid::Errors::DocumentNotFound
    render json: { message: 'category not found' }, status: :not_found
  end

  def category_params
    params.require(:category).permit(:category_code, :category_description)
  end
end
