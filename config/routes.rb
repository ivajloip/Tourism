Tourism::Application.routes.draw do
  resources :tags

  resources :provinces

  devise_for :users, :controllers => { :registrations => "registrations", :omniauth_callbacks => "users/omniauth_callbacks" }
  
  devise_scope :user do
    get "/logout" => "devise/sessions#destroy"
  end

  resources :users do
    member do
      put 'follow'
      put 'unfollow'
    end
  end

  resources :articles do 
    resources :comments do
      put 'like'
      put 'dislike'
    end

    member do
      put 'like'
      put 'dislike'
      put 'follow'
      put 'unfollow'
    end

    collection do
      get 'search'
    end
  end

  root :to => 'articles#index'
end
