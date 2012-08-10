require File.expand_path('../../test_helper', __FILE__)

class Oauth2ControllerTest < ActionController::TestCase

  def setup
    @code = 'G3Y6jU3a'
    @client_id = 's6BhdRkqt3'
    @client_secret = 'SplxlOBeZQQYbYS6WxSbIA'
    @access_token = '2YotnFZFEjr1zCsicMWpAA'
    @refresh_token = 'tGzv3JOkF0XG5Qx2TlKWIA'
    @expires_in = 3600
    @token_type = 'bearer'
    @redirect_uri = 'https://example.com'
    @token_response = {
                        :access_token => @access_token,
                        :refresh_token => @refresh_token,
                        :token_type => @token_type,
                        :expires_in =>  @expires_in,
                      }
    @default_params = { 
                        :client_id => @client_id,
                        :redirect_uri => @redirect_uri
                      }
  end

  test "should return bad request without any parameters provided" do
    get :authorize
    assert_response :bad_request
  end

  test "should redirect if parameters missing but redirect uri is present and valid" do
    request_params = { 
                      :redirect_uri => "https://example.com"
                     }
    get :authorize, request_params
    assert_redirected_to 'https://example.com?error=invalid_request&error_description=client_id%20required'
  end

  test "should redirect if missing grant type" do
    request_params = {
                      :client_id => "s6BhdRkqt3",
                      :redirect_uri => "https://example.com"
                     }
    get :authorize, request_params
    assert_redirected_to 'https://example.com?error=invalid_request&error_description=response_type%20or%20grant_type%20is%20required'
  end


  test "should redirect if missing response type" do
    request_params = {
                      :client_id => "s6BhdRkqt3",
                      :redirect_uri => "https://example.com"
                     }
    get :authorize, request_params
    assert_redirected_to 'https://example.com?error=invalid_request&error_description=response_type%20or%20grant_type%20is%20required'
  end

  test "should redirect if invalid response_type" do
    request_params = { 
                      :client_id => "s6BhdRkqt3",
                      :response_type => "invalid",
                      :redirect_uri => "https://example.com"
                     }
    get :authorize, request_params
    assert_redirected_to 'https://example.com?error=unsupported_response_type&error_description=response_type%20not%20supported'
  end

  # implicit grant
  
  test "should redirect if invalid client_id and response type code" do
    request_params = { 
                      :client_id => "s6BhdRkqt3",
                      :response_type => "code",
                      :redirect_uri => "https://example.com"
                     }
    get :authorize, request_params
    assert_redirected_to 'https://example.com?error=invalid_client&error_description=unknown%20client'
  end

  test "should redirect if invalid client_id and response type token" do
    request_params = { 
                      :client_id => "s6BhdRkqt3",
                      :response_type => "token",
                      :redirect_uri => "https://example.com"
                     }
    get :authorize, request_params
    assert_redirected_to 'https://example.com?error=invalid_client&error_description=unknown%20client'
  end

  test "should succeed if response type code and client id valid" do
    OAuth2::Server::RequestHandler.any_instance.stubs(:validate_client_id).returns(true)
    request_params = { 
                      :client_id => "s6BhdRkqt3",
                      :response_type => "code",
                      :redirect_uri => "https://example.com"
                     }
    assert_difference('OauthPendingRequest.count', 1) do
      get :authorize, request_params
    end
    assert_response :success
  end

  test "should succeed if response type token and client id valid" do
    OAuth2::Server::RequestHandler.any_instance.stubs(:validate_client_id).returns(true)
    request_params = { 
                      :client_id => "s6BhdRkqt3",
                      :response_type => "token",
                      :redirect_uri => "https://example.com"
                     }
    assert_difference('OauthPendingRequest.count', 1) do
      get :authorize, request_params
    end
    assert_response :success
  end
end
