# frozen_string_literal: true

class Category # rubocop:disable Style/Documentation
  include Mongoid::Document
  include Mongoid::Timestamps
  field :category_code, type: String
  field :category_description, type: String

  field :item_id, type: BSON::ObjectId

  def items
    Item.where(category_id: id)
  end
end
