Spotleef::Application.routes.draw do

  match "oauth2/authorize" => "oauth2#authorize", :via => [:get, :post]
  match "oauth2/token" => "oauth2#token", :via => [:get, :post]
  
end
