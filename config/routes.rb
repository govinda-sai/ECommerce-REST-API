# frozen_string_literal: true

Rails.application.routes.draw do
  resources :users do
    collection do
      post '/login', to: 'users#login'
    end
  end

  resources :categories do
    collection do
      get 'items_for_the_category'
    end
  end

  resources :items do
    collection do
      get 'find_by_title'
    end
    collection do
      get 'find_by_category'
    end
  end

  resources :orders do
    collection do
      get 'orders_by_user'
    end
  end

  # config/routes.rb
  get 'swagger-ui', to: 'swagger#index'
end
