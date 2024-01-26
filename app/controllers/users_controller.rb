# frozen_string_literal: true

class UsersController < ApplicationController # rubocop:disable Style/Documentation
  before_action :set_user, only: %i[show update destroy]

  def index
    @users = User.all
    render json: @users.map do |user|
      {
        user_id: user.id, first_name: user.first_name, last_name: user.last_name, email: user.email,
        phone: user.primary_phone, date_of_birth: user.dob, user_account_status: user.status
      }
    end
  end

  def show
    return unless @user

    render json: { user: { user_id: @user.id, first_name: @user.first_name, last_name: @user.last_name, email: @user.email, # rubocop:disable Layout/LineLength
                           phone: @user.primary_phone, date_of_birth: @user.dob, user_account_status: @user.status } }
  end

  def create
    @user = User.new(user_params)
    if @user.save
      render json: @user, status: :created
    else
      render json: { message: "user couldn't be created", errors: @user.errors.full_messages },
             status: :unprocessable_entity
    end
  end

  def update
    return unless @user

    if @user.update(user_params)
      render json: @user
    else
      render json: { message: 'user couldn\'t be updated' }, status: :unprocessable_entity
    end
  end

  def destroy
    return unless @user

    @user.destroy
    render json: { message: 'user deleted successfully' }, status: :ok
  end

  def login
    user = User.find_by(email: params[:email])

    if user.status == 'active'
      if user && authenticate_user(user, params[:password])
        render json: { authentication_token: user.authentication_token }
      else
        render json: { error: 'Invalid email or password' }, status: :unauthorized
      end
    else
      render json: { message: 'user is inactive' }
    end
  end

  private

  def set_user
    @user = User.find(params[:id])
  rescue Mongoid::Errors::DocumentNotFound
    render json: { message: 'user not found' }, status: :not_found
  end

  def user_params
    params.require(:user).permit(:first_name, :last_name, :email, :password, :dob, :status, primary_phone: [])
  end

  def authenticate_user(user, password)
    salt, hashed_password = user.password.split('$')

    hashed_attempt = user.hash_with_salt(password, salt)

    hashed_attempt == hashed_password
  end
end
