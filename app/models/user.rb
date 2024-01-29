# frozen_string_literal: true

# app/models/user.rb

class User # rubocop:disable Style/Documentation
  include Mongoid::Document
  include Mongoid::Timestamps

  field :first_name, type: String
  field :last_name, type: String
  field :email, type: String
  field :password, type: String
  field :primary_phone, type: Array
  field :dob, type: Date
  field :status, type: String
  field :authentication_token, type: String
  field :order_id, type: BSON::ObjectId

  # validate :password_presence, on: :create

  before_save :encrypt_password
  before_save :generate_authentication_token

  before_validation :validation

  def validation # rubocop:disable Metrics/AbcSize,Metrics/CyclomaticComplexity,Metrics/PerceivedComplexity,Metrics/MethodLength
    errors.add(:first_name, '- first name can\'t be blank') unless first_name.present?
    errors.add(:last_name, '- last name can\'t be blank') unless last_name.present?
    errors.add(:email, '- invalid email address') if email.present? && !/\A[\w\d_.]+@[\w\d]+[.]\w+\z/.match?(email)
    errors.add(:email, '- email can\'t be blank') unless email.present?
    errors.add(:password, '- password can\'t be blank') unless password.present?
    errors.add(:password, '- password must be of 6 character length') if password.present? && password.length < 6
    if dob.present?
      errors.add(:dob, '- must be 18 years old') unless dob < (Date.today - 18.years)
    else
      errors.add(:dob, '- date of birth can\'t be blank')
    end
    unless status == 'active' || status == 'inactive'
      errors.add(:status, '- status can either be \'active\' or \'inactive\'')
    end
    return if status.present?

    errors.add(:status, 'status can\'t be blank')
  end

  def orders
    Order.where(user_id: id)
  end

  # def password_presence
  #   errors.add(:password, 'Password can\'t be blank') unless password.present?
  # end

  def encrypt_password
    return unless password.present?

    salt = SecureRandom.hex
    self.password = "#{salt}$#{hash_with_salt(password, salt)}"
  end

  def hash_with_salt(password, salt)
    Digest::SHA256.hexdigest("#{salt}#{password}")
  end

  def generate_authentication_token
    self.authentication_token = SecureRandom.hex
  end
end
