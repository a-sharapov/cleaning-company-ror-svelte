Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      get "get_user", action: :get_user, controller: :users
      get "get_users", action: :get_users, controller: :users
      post "create_user", action: :create_user, controller: :users
      put "update_user", action: :update_user, controller: :users
      delete "delete_user", action: :delete_user, controller: :users
      
      post "login", action: :login, controller: :authentification
      get "logout", action: :logout, controller: :authentification
    end
  end
end
