Rails.application.routes.draw do
  # Routes are appropriately RESTful and are limited only to the actions available in controllers
  namespace :admin do
    resources :dashboard, only: [:index]
    resources :merchants, only: [:index, :show, :new, :create, :edit, :update]
    resources :invoices, only: [:index, :show, :update]
  end

  resources :merchants do
    resources :items, only: [:index, :show, :update, :edit, :new, :create]
    resources :invoices, only: [:index, :show, :update]
    resources :dashboard, only: [:index]
    resources :bulk_discounts, only: [:index, :show, :new, :create, :destroy, :edit, :update]
    resources :holiday_bulk_discounts, only: [:new, :create]
  end
end
