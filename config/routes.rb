Spotleef::Application.routes.draw do
  match "oauth2/register"                  => "oauth2#register",              :via => :get,                :as => :oauth2_register
  match "oauth2/process_authorization/:id" => "oauth2#process_authorization", :via => [:post],             :as => :oauth2_process_authorization
  match "oauth2/authorize"                 => "oauth2#authorize",             :via => [:get, :post],       :as => :oauth2_authorize
  match "oauth2/token"                     => "oauth2#token",                 :via => [:get, :post],       :as => :oauth2_token
end
