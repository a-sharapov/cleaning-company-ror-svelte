Rails.application.routes.draw do
  namespace :api do
    get '/', to: "v1/api#index"
    get 'v1', to: "v1/api#endpoints"

    namespace :v1 do
      get "assets/init", to: "assets#init"
      get "assets/:slug", to: "assets#index"

      get "users", to: "users#index"
      post "users", to: "users#new"
      get "users/:login", to: "users#show"
      put "users/:login", to: "users#update"
      delete "users/:login", to: "users#destroy"

      get "companies", to: "company_profile#index"
      post "companies", to: "company_profile#new"
      get "companies/:slug", to: "company_profile#show"
      put "companies/:slug", to: "company_profile#update"
      delete "companies/:slug", to: "company_profile#destroy"
      
      post "auth", to: "authentification#login"
      delete "auth", to: "authentification#logout"
      put "auth", to: "authentification#refresh"
      put "restore/:code", to: "authentification#unlock"
      get "confirm", to: "authentification#confirm"

      get "manager", to: "management#index"
      get "manager/add/:login", to: "management#add"
      put "manager/ban/:login", to: "management#ban"
    end
  end
end
