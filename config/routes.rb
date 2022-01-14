Rails.application.routes.draw do

  namespace :admin do
    resources :dashboard, only: [:index]
    resources :merchants, only: [:index, :show, :new, :create, :edit, :update]
    resources :invoices, only: [:index, :show, :update]
  end

  resources :merchants do
    resources :items, only: [:index, :show, :update, :new, :create]
    resources :invoices, only: [:index, :show, :update]
    resources :dashboard, only: [:index]
  end
end
