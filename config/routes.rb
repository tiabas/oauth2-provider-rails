Spotleef::Application.routes.draw do
  resource :client_applications

  root :to => "home#index"
  
  get "home/index"

  match "oauth2/register"                  => "oauth2#register",              :via => :get,                :as => :oauth2_register
  match "oauth2/approval/:signature"       => "oauth2#process_authorization", :via => [:post],             :as => :oauth2_approval
  match "oauth2/authorize"                 => "oauth2#authorize",             :via => [:get, :post],       :as => :oauth2_authorize
  match "oauth2/token"                     => "oauth2#token",                 :via => [:get, :post],       :as => :oauth2_token
end
