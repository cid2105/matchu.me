Matchume::Application.routes.draw do
 
  root :to => "home#index"

  # match '/poll' => 'home#poll', :as => :poll, :via => :get

  resources :users, :only => [:index, :edit, :update, :destroy] do
  	collection do
      get 'search'
      get 'autocomplete'
      post 'like'
      post 'prev'
      post 'next'
      post 'goto'
      post 'reset_new_match_count'
    end

  end
  match '/auth/:provider/callback' => 'sessions#create'
  match '/signin' => 'sessions#new', :as => :signin
  match '/signout' => 'sessions#destroy', :as => :signout
  match '/auth/failure' => 'sessions#failure'
  # mount Resque::Server, :at => "/resque"
  
end
