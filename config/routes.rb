Rails.application.routes.draw do
  resources :records do
    collection do
      get :search
      get :fetch_release
    end
    member do
      post :fetch_cover
    end
  end
  resources :artists
  resources :genres do
    collection do
      get :search
    end
  end

  root "records#index"
end
