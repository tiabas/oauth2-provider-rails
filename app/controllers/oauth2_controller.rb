class Oauth2Controller < ApplicationController

  # before_filter :create_oauth_client_request, :only => [:authorize, :token]

  # request authorization
  def authorize
  # @params:
  #  client_id     
  #
  # Authorization code
  #   response_type, redirect_uri
  # 
  # Resource Owner Credentials   
  #   grant_type, username, password
  #
  # Client Credentials
  #   grant_type, client_secret
    request = OAuth2::Server::Request.new params.symbolize_keys
    handler = OAuth2::Server::RequestHandler.new(request, {
              :user_datastore => User,
              :client_datastore => OauthClientApplication,
              :token_datastore => OauthAccessToken,
              :code_datastore => OauthAuthorizationCode
              })
    redirect_to handler.authorization_redirect_uri, :status => :found
  end

  def process_authorization
    allow = params.fetch('allow', false) && true
    redirect_to @oauth2_client_request.authorization_redirect_uri(allow), :status => :found
  end

  # access_token, refresh_token
  def token
  # @params:
  #  client_id     
  #  client_secret
  user = User.first
  request = OAuth2::Server::Request.new params.symbolize_keys
  handler = OAuth2::Server::RequestHandler.new(request, {
            :user_datastore => User,
            :client_datastore => OauthClientApplication,
            :token_datastore => OauthAccessToken,
            :code_datastore => OauthAuthorizationCode
            })
  return render :json => handler.fetch_access_token(user).to_hsh, :status => :ok
  end

  def register
  end

  def process_registration

  end

end
