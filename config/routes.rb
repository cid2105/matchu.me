Matchume::Application.routes.draw do
 
  root :to => "home#index"

  resources :users, :only => [:index, :show, :edit, :update ] do
  	collection do
      get 'search'
      get 'autocomplete'
      post 'like'
      post 'prev'
      post 'next'
    end

  end
  match '/auth/:provider/callback' => 'sessions#create'
  match '/signin' => 'sessions#new', :as => :signin
  match '/signout' => 'sessions#destroy', :as => :signout
  match '/auth/failure' => 'sessions#failure'
  mount Resque::Server, :at => "/resque"
  
end
