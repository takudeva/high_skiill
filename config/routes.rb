Rails.application.routes.draw do

  root to: 'homes#top'
  get 'about' => 'homes#about', as: 'about'
  resource :users, only: [:edit, :update] do
    collection do
      get 'my_page'
      get 'confirm'
      patch 'withdrawal'
    end
  end
  resource :questions, only: [:show]  do
    collection do
      post 'answer'
      get 'answer' => 'questions#result'
      get 'score'
    end
  end
  resources :reviews, only: [:index] do
    collection do
      get 'question'
      post 'answer'
      get 'answer' => 'reviews#result'
    end
  end
  devise_for :users
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
