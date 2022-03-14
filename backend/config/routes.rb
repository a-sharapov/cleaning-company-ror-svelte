Rails.application.routes.draw do
  namespace :api do
    get '/', to: "v1/api#index"
    get 'v1', to: "v1/api#endpoints"

    namespace :v1 do
      get "assets/init", to: "assets#init"
      get "assets/:slug", to: "assets#index"

      get "users", to: "users#index"
      post "users", to: "users#new"
      get "user/:login", to: "users#show"
      put "user/:login", to: "users#update"
      put "user/:login/password", to: "users#change_password"
      delete "user/:login", to: "users#destroy"
      get 'avatar/:login', to: "users#avatar"
      get 'sessions/:login', to: "users#sessions"

      get "companies", to: "company_profile#index"
      post "companies", to: "company_profile#new"
      get ":user/company", to: "company_profile#show_to_user"
      get "company/:slug", to: "company_profile#show"
      get 'logotype/:slug', to: "company_profile#logotype"
      put "company/:slug", to: "company_profile#update"

      get "reviews", to: "review#index"
      post "reviews", to: "review#new"
      get "review/:slug", to: "review#show"
      put "review/:slug", to: "review#update"

      get "events", to: "cleaning_event#index"
      post "events", to: "cleaning_event#new"
      get "event/:slug", to: "cleaning_event#show"
      put "event/:slug", to: "cleaning_event#update"
      delete "event/:slug", to: "cleaning_event#destroy"
      
      post "auth", to: "authentification#login"
      delete "auth", to: "authentification#logout"
      put "auth", to: "authentification#refresh"
      put "restore/:code", to: "authentification#unlock"
      get "confirm", to: "authentification#confirm"
      delete "session/:id", to: "authentification#remove"

      get "manager", to: "management#index"
      get "manager/add/:login", to: "management#add"
      put "manager/ban/:login", to: "management#ban"
    end
  end
end
