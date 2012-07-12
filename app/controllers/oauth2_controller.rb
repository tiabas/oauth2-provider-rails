class Oauth2Controller < ApplicationController

	before_filter :create_oauth2_client_request
	before_filter :verify_oauth2_client_id
	before_filter :verify_oauth2_response_type, :only => :authorize

	# request authorization
  def authorize
  	# render authorization page
  end

  def process_authorization
  	allow = params.fetch('allow', false) && true
  	redirect_to @oauth2_client_request.authorization_redirect_uri(allow), :status => :found
  end

  # access_token, refresh_token
  def token

  end

  def register

  end

end
