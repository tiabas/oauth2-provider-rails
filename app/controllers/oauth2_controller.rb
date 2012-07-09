class Oauth2Controller < ApplicationController
	
	before_filter :create_oauth2_client_request
	before_filter :verify_oauth2_client_id
	before_filter :verify_oauth2_response_type, :only => :authorize

  def authorize
  	redirect_to @oauth2_client_request.authorization_redirect_uri, :status => :found
  end

  def token

  end
end
