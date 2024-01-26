# frozen_string_literal: true

module Read # rubocop:disable Style/Documentation
  def index
    @categories = Category.all.map do |category|
      {
        category_id: category.id, category_code: category.category_code, category_description: category.category_description # rubocop:disable Layout/LineLength
      }
    end
    render json: @categories
  end

  def show(_category_id)
    @category = Category.find_by(id: params[:id])
    render json: @category
  end
end
