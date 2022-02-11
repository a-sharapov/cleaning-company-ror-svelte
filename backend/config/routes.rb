Rails.application.routes.draw do
  namespace :api do
    get '/', to: "v1/api#index"
    get 'v1', to: "v1/api#endpoints"

    namespace :v1 do
      get "users", to: "users#index"
      post "users", to: "users#new"
      get "users/:id", to: "users#show"
      put "users/:id", to: "users#update"
      delete "users/:id", to: "users#destroy"
      
      post "auth/login", to: "authentification#login"
      delete "auth/logout", to: "authentification#logout"
      get "auth/refresh", to: "authentification#refresh"
    end
  end
end
