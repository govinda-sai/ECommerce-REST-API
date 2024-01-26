# frozen_string_literal: true

class Item # rubocop:disable Style/Documentation
  include Mongoid::Document
  include Mongoid::Timestamps

  field :title, type: String
  field :description, type: String
  field :price, type: Float

  field :category_id, type: BSON::ObjectId
  field :order_id, type: BSON::ObjectId

  def category
    Category.find(category_id)
  end

  def orders
    Order.where(item_id: id)
  end
end
