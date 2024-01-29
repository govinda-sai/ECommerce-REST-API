# frozen_string_literal: true

class Order # rubocop:disable Style/Documentation
  include Mongoid::Document
  include Mongoid::Timestamps

  field :quantity, type: Integer
  field :total_price, type: Float

  field :item_id, type: BSON::ObjectId
  field :user_id, type: BSON::ObjectId

  before_validation :calculate_total_price

  def calculate_total_price
    self.total_price = quantity * item.price if item.present?
  end

  def item
    Item.find(item_id)
  end

  def user
    User.find(user_id)
  end
end
