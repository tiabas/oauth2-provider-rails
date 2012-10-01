require File.expand_path("../../test_helper", __FILE__)

class Oauth2ControllerTest < ActionController::TestCase

  def setup
    @code = "G3Y6jU3a"
    @client_id = "s6BhdRkqt3"
    @client_secret = "SplxlOBeZQQYbYS6WxSbIA"
    @access_token = "2YotnFZFEjr1zCsicMWpAA"
    @refresh_token = "tGzv3JOkF0XG5Qx2TlKWIA"
    @expires_in = 3600
    @token_type = "Bearer"
    @state = "xyz"
    @redirect_uri = "https://example.com/oauth/v2/cb"
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
    @user = create_dummy_user
    @client_app = ClientApplication.create!(
      :name => 'dummy app',
      :website => 'https://example.com',
      :description => 'a dummy app for testing OAuth2',
      :client_type => 1,
      :redirect_uri => @redirect_uri
    )
  end

  test "should return bad request without any parameters provided" do
    get :authorize
    assert_response :success
    # TODO: include error message to user
  end

  test "should redirect if parameters missing but redirect uri is present and valid" do
    request_params = { 
                      :redirect_uri => @redirect_uri
                     }
    get :authorize, request_params
    assert_redirected_to "#{@redirect_uri}?error=invalid_request&error_description=client_id%20required"
  end

  test "should redirect if missing grant type" do
    request_params = {
                      :client_id => "s6BhdRkqt3",
                      :redirect_uri => @redirect_uri
                     }
    get :authorize, request_params
    assert_redirected_to "#{@redirect_uri}?error=invalid_request&error_description=response_type%20or%20grant_type%20is%20required"
  end


  test "should redirect if missing response type" do
    request_params = {
                      :client_id => "s6BhdRkqt3",
                      :redirect_uri => @redirect_uri
                     }
    get :authorize, request_params
    assert_redirected_to "#{@redirect_uri}?error=invalid_request&error_description=response_type%20or%20grant_type%20is%20required"
  end

  test "should redirect if invalid response_type" do
    request_params = { 
                      :client_id => "s6BhdRkqt3",
                      :response_type => "invalid",
                      :redirect_uri => @redirect_uri,
                      :state => @state
                     }
    get :authorize, request_params
    assert_redirected_to "#{@redirect_uri}?error=unsupported_response_type&error_description=response_type%20not%20supported"
  end

  # implicit grant
  
  test "should redirect if invalid client_id and response type code" do
    request_params = { 
                      :client_id => "s6BhdRkqt3",
                      :response_type => "code",
                      :redirect_uri => @redirect_uri,
                      :state => @state
                     }
    get :authorize, request_params
    assert_redirected_to "#{@redirect_uri}?error=invalid_client&error_description=unknown%20client"
  end

  test "should redirect if invalid client_id and response type token" do
    request_params = { 
                      :client_id => "s6BhdRkqt3",
                      :response_type => "token",
                      :redirect_uri => @redirect_uri,
                      :state => @state
                     }
    get :authorize, request_params
    assert_redirected_to "#{@redirect_uri}?error=invalid_client&error_description=unknown%20client"
  end

  test "should render authorization page if response type code and client id valid" do
    login_user(@user)
    OAuth2::Server::RequestHandler.any_instance.stubs(:verify_client_id).returns(true)
    request_params = { 
                      :client_id => "s6BhdRkqt3",
                      :response_type => "code",
                      :redirect_uri => @redirect_uri,
                      :state => @state
                     }
    assert_difference("OauthPendingRequest.count", 1) do
      get :authorize, request_params
    end
    assert_response :success
  end

  test "should render authorization page if response type token and client id valid" do
    login_user(@user)
    OAuth2::Server::RequestHandler.any_instance.stubs(:verify_client_id).returns(@client_app)
    request_params = { 
                      :client_id => "s6BhdRkqt3",
                      :response_type => "token",
                      :redirect_uri => @redirect_uri,
                      :state => @state
                     }
    assert_difference("OauthPendingRequest.count", 1) do
      get :authorize, request_params
    end
    assert_response :success
  end

  test "should redirect with authorization code if approval prompt is not forced" do
    login_user(@user)
    OAuth2::Server::RequestHandler.any_instance.stubs(:verify_client_id).returns(@client_app)
    request_params = { 
                      :client_id => "s6BhdRkqt3",
                      :response_type => "code",
                      :redirect_uri => @redirect_uri,
                      :state => @state,
                      :approval_prompt => false
                     }
    get :authorize, request_params
    assert_redirected_to "#{@redirect_uri}?code=#{@code}&state=#{@state}"
  end

  test "should redirect with access token if approval prompt is not forced" do
    login_user(@user)
    OAuth2::Server::RequestHandler.any_instance.stubs(:verify_client_id).returns(@client_app)
    request_params = { 
                      :client_id => "s6BhdRkqt3",
                      :response_type => "token",
                      :redirect_uri => @redirect_uri,
                      :state => @state,
                      :approval_prompt => false
                     }
    get :authorize, request_params
    assert_redirected_to "#{@redirect_uri}#access_token=#{@access_token}&token_type=Bearer&expires_in=3600&refresh_token=#{@refresh_token}&state=#{@state}"
  end

  test "should redirect with error message if user denies request" do
    login_user(@user)
    pending_request = OauthPendingRequest.create!(
                      :client_id => @client_app.client_id,
                      :response_type => "token",
                      :redirect_uri => @redirect_uri,
                      :state => @state
                      )
    post :process_authorization, :id => pending_request.id, :allow_access => false
    assert_redirected_to "#{@redirect_uri}?error=access_denied&error_description=the%20user%20denied%20your%20request"
  end

  test "should if response type is token redirect with token if user approves request" do
    login_user(@user)
    OauthAccessToken.any_instance.stubs(:token).returns(@access_token)
    OauthAccessToken.any_instance.stubs(:refresh_token).returns(@refresh_token)
    pending_request = OauthPendingRequest.create!(
                      :client_id => @client_app.client_id,
                      :response_type => "token",
                      :redirect_uri => @redirect_uri,
                      :state => @state
                      )
    post :process_authorization, :id => pending_request.id, :allow_access => true
    assert_redirected_to "#{@redirect_uri}#access_token=#{@access_token}&token_type=Bearer&expires_in=3600&refresh_token=#{@refresh_token}&state=#{@state}"
  end

  test "should if response type is token redirect with code if user approves request" do
    # login_user(@user)
    OauthAuthorizationCode.any_instance.stubs(:code).returns(@code)
    pending_request = OauthPendingRequest.create!(
                      :client_id => @client_app.client_id,
                      :response_type => "code",
                      :redirect_uri => @redirect_uri,
                      :state => @state
                      )
    post :process_authorization, :id => pending_request.id, :allow_access => true
    assert_redirected_to "#{@redirect_uri}?code=#{@code}&state=#{@state}"
  end

  test "should if grant type is authorization code respond with token" do
    login_user(@user)
    OauthAccessToken.any_instance.stubs(:token).returns("aXsDTMH1cMx4G14TYfQMDuxBGeWjvP1OoaT9D70uP2zP9QMxMzQ0NjYzODE1")
    OauthAccessToken.any_instance.stubs(:refresh_token).returns("e22RFX9UHaKjHmqbF3J7Z5AV1eYlk21CczuAkgy3KuWhN5w4NVMxMzQ0NjYzODE1")
    auth_code = OauthAuthorizationCode.create!(
                  :client_application_id => @client_app.id,
                  :code => @code,
                  :redirect_uri => @redirect_uri
                ) 
    request_params = {
                      :client_id => @client_app.client_id,
                      :grant_type => "authorization_code",
                      :code => @code,
                      :redirect_uri => @redirect_uri
                      }
    post :token, request_params
    resp = JSON.parse(response.body).symbolize_keys
    assert_equal "aXsDTMH1cMx4G14TYfQMDuxBGeWjvP1OoaT9D70uP2zP9QMxMzQ0NjYzODE1", resp[:access_token]
    assert_equal "e22RFX9UHaKjHmqbF3J7Z5AV1eYlk21CczuAkgy3KuWhN5w4NVMxMzQ0NjYzODE1", resp[:refresh_token]
    assert_equal "Bearer", resp[:token_type]
    assert_equal 3600, resp[:expires_in]
  end

  test "should if grant type is password respond with token" do
    login_user(@user)
    User.stubs(:authenticate).returns(true)
    OauthAccessToken.any_instance.stubs(:token).returns("aXsDTMH1cMx4G14TYfQMDuxBGeWjvP1OoaT9D70uP2zP9QMxMzQ0NjYzODE1")
    OauthAccessToken.any_instance.stubs(:refresh_token).returns("e22RFX9UHaKjHmqbF3J7Z5AV1eYlk21CczuAkgy3KuWhN5w4NVMxMzQ0NjYzODE1")
    request_params = {
                      :client_id => @client_app.client_id,
                      :grant_type => "password",
                      :username => 'username',
                      :password => 'letmein',
                      :redirect_uri => @redirect_uri
                      }
    post :token, request_params
    resp = JSON.parse(response.body).symbolize_keys
    assert_equal "aXsDTMH1cMx4G14TYfQMDuxBGeWjvP1OoaT9D70uP2zP9QMxMzQ0NjYzODE1", resp[:access_token]
    assert_equal "e22RFX9UHaKjHmqbF3J7Z5AV1eYlk21CczuAkgy3KuWhN5w4NVMxMzQ0NjYzODE1", resp[:refresh_token]
    assert_equal "Bearer", resp[:token_type]
    assert_equal 3600, resp[:expires_in]
  end

  test "should if grant type is client credentials respond with token" do
    OauthAccessToken.any_instance.stubs(:token).returns("aXsDTMH1cMx4G14TYfQMDuxBGeWjvP1OoaT9D70uP2zP9QMxMzQ0NjYzODE1")
    OauthAccessToken.any_instance.stubs(:refresh_token).returns("e22RFX9UHaKjHmqbF3J7Z5AV1eYlk21CczuAkgy3KuWhN5w4NVMxMzQ0NjYzODE1")
    request_params = {
                      :client_id => @client_app.client_id,
                      :client_secret => @client_app.client_secret,
                      :grant_type => "client_credentials",
                      :redirect_uri => @redirect_uri
                      }
    post :token, request_params
    resp = JSON.parse(response.body).symbolize_keys
    assert_equal "aXsDTMH1cMx4G14TYfQMDuxBGeWjvP1OoaT9D70uP2zP9QMxMzQ0NjYzODE1", resp[:access_token]
    assert_equal "e22RFX9UHaKjHmqbF3J7Z5AV1eYlk21CczuAkgy3KuWhN5w4NVMxMzQ0NjYzODE1", resp[:refresh_token]
    assert_equal "Bearer", resp[:token_type]
    assert_equal 3600, resp[:expires_in]
  end

  test "should if grant type is refresh token respond with token" do
    OauthAccessToken.any_instance.stubs(:token).returns("aXsDTMH1cMx4G14TYfQMDuxBGeWjvP1OoaT9D70uP2zP9QMxMzQ0NjYzODE1")
    OauthAccessToken.any_instance.stubs(:refresh_token).returns("e22RFX9UHaKjHmqbF3J7Z5AV1eYlk21CczuAkgy3KuWhN5w4NVMxMzQ0NjYzODE1")
    dummy_token = OauthAccessToken.new(
                    :client_id => @client_app.id,
                    :user_id => @user.id,
                    :token => 'aXsDTMH1cMx4G14TYfQMDuxBGeWjvP1OoaT9D70uP2zP9QMxMzQ0NjYzODE1',
                    :token_type => @token_type,
                    :refresh_token => 'e22RFX9UHaKjHmqbF3J7Z5AV1eYlk21CczuAkgy3KuWhN5w4NVMxMzQ0NjYzODE1',
                    :expires_in => @expires_in
                  )
    OauthAccessToken.stubs(:generate_from_refresh_token).returns(dummy_token)
    request_params = {
                      :client_id => @client_app.client_id,
                      :refresh_token => "e22RFX9UHaKjHmqbF3J7Z5AV1eYlk21CczuAkgy3KuWhN5w4NVMxMzQ0NjYzODE1",
                      :grant_type => "refresh_token",
                      :redirect_uri => @redirect_uri
                      }
    post :token, request_params
    resp = JSON.parse(response.body).symbolize_keys
    assert_equal "aXsDTMH1cMx4G14TYfQMDuxBGeWjvP1OoaT9D70uP2zP9QMxMzQ0NjYzODE1", resp[:access_token]
    assert_equal "e22RFX9UHaKjHmqbF3J7Z5AV1eYlk21CczuAkgy3KuWhN5w4NVMxMzQ0NjYzODE1", resp[:refresh_token]
    assert_equal "Bearer", resp[:token_type]
    assert_equal 3600, resp[:expires_in]
  end
end
