class Oauth2Controller < ApplicationController

  before_filter :create_oauth2_client_request
  before_filter :verify_oauth2_client_id
  before_filter :verify_oauth2_response_type, :only => :authorize

  # request authorization
  def authorize
  # @params:
  #  client_id     
  #  client_secret
  #  redirect_uri
  #
  #  Resource Owner Credentials   
  #   grant_type => password
  #   username
  #   password
  #
  #  Client Credentials
  #   grant_type => client_credentials  
  #
  #  
  #
  #
  #
  #
  #
  #
  #
  #
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
  #
  #  Resource Owner Credentials   
  #   grant_type => password
  #   username
  #   password
  #
  #  Client Credentials
  #   grant_type => client_credentials  
  #
  #  Implicit Grant  
  #   no grant type
  #
  #  Authorization Grant
  #   grant_type => client_credentials  
  #
  #  Refresh token
  #   grant_type => refresh_token
  #
  end

  def register

  end

end
