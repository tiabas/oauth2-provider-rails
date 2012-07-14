Spotleef::Application.routes.draw do
  match "oauth2/register"     => "oauth2#register",  :via => :get
  match "oauth2/authorize"    => "oauth2#authorize", :via => [:get, :post]
  match "oauth2/token"        => "oauth2#token",     :via => [:get, :post]
end
