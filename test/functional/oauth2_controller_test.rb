require File.expand_path("../../test_helper", __FILE__)

class Oauth2ControllerTest < ActionController::TestCase

  def setup
    @code = "G3Y6jU3a"
    @access_token = "2YotnFZFEjr1zCsicMWpAA"
    @refresh_token = "tGzv3JOkF0XG5Qx2TlKWIA"
    @expires_in = 3600
    @token_type = "Bearer"
    @state = "xyz"

    @user = create_dummy_user
    @client_app = create_dummy_client_app
    @client_id = @client_app.client_id
    @client_secret = @client_app.client_secret
    @redirect_uri = @client_app.redirect_uri

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
    request_params = { 
                      :client_id => @client_app.client_id,
                      :response_type => "code",
                      :redirect_uri => @redirect_uri,
                      :state => @state
                     }
    assert_difference("PendingAuthorizationRequest.count", 1) do
      get :authorize, request_params
    end
    assert_response :success
  end

  test "should render authorization page if response type token and client id valid" do
    login_user(@user)
    request_params = { 
                      :client_id => @client_app.client_id,
                      :response_type => "token",
                      :redirect_uri => @redirect_uri,
                      :state => @state
                     }
    assert_difference("PendingAuthorizationRequest.count", 1) do
      get :authorize, request_params
    end
    assert_response :success
  end

  test "should redirect with authorization code if approval prompt is not forced" do
    login_user(@user)
    request_params = { 
                      :client_id => @client_app.client_id,
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
    request_params = { 
                      :client_id => @client_app.client_id,
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
    pending_request = PendingAuthorizationRequest.new(
                      :client_id => @client_app.client_id,
                      :response_type => "token",
                      :redirect_uri => @redirect_uri,
                      :state => @state)
    pending_request.user_id = @user.id
    pending_request.save
    post :process_authorization, :signature => pending_request.signature, :allow_access => false
    assert_redirected_to "#{@redirect_uri}?error=access_denied&error_description=the%20user%20denied%20your%20request"
  end

  test "should if response type is token redirect with token if user approves request" do
    login_user(@user)
    AccessToken.any_instance.stubs(:token).returns(@access_token)
    AccessToken.any_instance.stubs(:refresh_token).returns(@refresh_token)
    pending_request = PendingAuthorizationRequest.new(
                      :client_id => @client_app.client_id,
                      :response_type => "token",
                      :redirect_uri => @redirect_uri,
                      :state => @state)
    pending_request.user_id = @user.id
    pending_request.save!
    post :process_authorization, :signature => pending_request.signature, :allow_access => true
    assert_redirected_to "#{@redirect_uri}#access_token=#{@access_token}&token_type=Bearer&expires_in=3600&refresh_token=#{@refresh_token}&state=#{@state}"
  end

  test "should if response type is token redirect with code if user approves request" do
    login_user(@user)
    AuthorizationCode.any_instance.stubs(:code).returns(@code)
    pending_request = PendingAuthorizationRequest.new(
                      :client_id => @client_app.client_id,
                      :response_type => "code",
                      :redirect_uri => @redirect_uri,
                      :state => @state)
    pending_request.user_id = @user.id
    pending_request.save!
    post :process_authorization, :signature => pending_request.signature, :allow_access => true
    assert_redirected_to "#{@redirect_uri}?code=#{@code}&state=#{@state}"
  end

  test "should if grant type is authorization code respond with token" do
    login_user(@user)
    AccessToken.any_instance.stubs(:token).returns("aXsDTMH1cMx4G14TYfQMDuxBGeWjvP1OoaT9D70uP2zP9QMxMzQ0NjYzODE1")
    AccessToken.any_instance.stubs(:refresh_token).returns("e22RFX9UHaKjHmqbF3J7Z5AV1eYlk21CczuAkgy3KuWhN5w4NVMxMzQ0NjYzODE1")
    auth_code = AuthorizationCode.generate_authorization_code(
                  :client => @client_app,
                  :redirect_uri => @redirect_uri,
                  :user => @user
                )
    request_params = {
                      :client_id => @client_app.client_id,
                      :client_secret => @client_app.client_secret,
                      :grant_type => "authorization_code",
                      :code => auth_code,
                      :redirect_uri => @redirect_uri
                      }
    post :token, request_params
    assert_response :success
    resp = JSON.parse(response.body).symbolize_keys
    assert_equal "aXsDTMH1cMx4G14TYfQMDuxBGeWjvP1OoaT9D70uP2zP9QMxMzQ0NjYzODE1", resp[:access_token]
    assert_equal "e22RFX9UHaKjHmqbF3J7Z5AV1eYlk21CczuAkgy3KuWhN5w4NVMxMzQ0NjYzODE1", resp[:refresh_token]
    assert_equal "Bearer", resp[:token_type]
    assert_equal 3600, resp[:expires_in]
  end

  test "should if grant type is password respond with token" do
    login_user(@user)
    User.stubs(:authenticate).returns(true)
    AccessToken.any_instance.stubs(:token).returns("aXsDTMH1cMx4G14TYfQMDuxBGeWjvP1OoaT9D70uP2zP9QMxMzQ0NjYzODE1")
    AccessToken.any_instance.stubs(:refresh_token).returns("e22RFX9UHaKjHmqbF3J7Z5AV1eYlk21CczuAkgy3KuWhN5w4NVMxMzQ0NjYzODE1")
    request_params = {
                      :client_id => @client_app.client_id,
                      :client_secret => @client_app.client_secret,
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
    AccessToken.any_instance.stubs(:token).returns("aXsDTMH1cMx4G14TYfQMDuxBGeWjvP1OoaT9D70uP2zP9QMxMzQ0NjYzODE1")
    AccessToken.any_instance.stubs(:refresh_token).returns("e22RFX9UHaKjHmqbF3J7Z5AV1eYlk21CczuAkgy3KuWhN5w4NVMxMzQ0NjYzODE1")
    request_params = {
                      :client_id => @client_app.client_id,
                      :client_secret => @client_app.client_secret,
                      :grant_type => "client_credentials",
                      :redirect_uri => @redirect_uri
                      }
    post :token, request_params
    assert_response :success
    resp = JSON.parse(response.body).symbolize_keys
    assert_equal "aXsDTMH1cMx4G14TYfQMDuxBGeWjvP1OoaT9D70uP2zP9QMxMzQ0NjYzODE1", resp[:access_token]
    assert_equal "e22RFX9UHaKjHmqbF3J7Z5AV1eYlk21CczuAkgy3KuWhN5w4NVMxMzQ0NjYzODE1", resp[:refresh_token]
    assert_equal "Bearer", resp[:token_type]
    assert_equal 3600, resp[:expires_in]
  end

  test "should if grant type is refresh token respond with token" do
    dummy_token = AccessToken.create!(
                    :client_id => @client_app.id,
                    :user_id => @user.id,
                    :token => 'aXsDTMH1cMx4G14TYfQMDuxBGeWjvP1OoaT9D70uP2zP9QMxMzQ0NjYzODE1',
                    :token_type => @token_type,
                    :refresh_token => 'e22RFX9UHaKjHmqbF3J7Z5AV1eYlk21CczuAkgy3KuWhN5w4NVMxMzQ0NjYzODE1',
                    :expires_in => @expires_in
                  )
    request_params = {
                      :client_id => @client_app.client_id,
                      :client_secret => @client_app.client_secret,
                      :refresh_token => "e22RFX9UHaKjHmqbF3J7Z5AV1eYlk21CczuAkgy3KuWhN5w4NVMxMzQ0NjYzODE1",
                      :grant_type => "refresh_token",
                      :redirect_uri => @redirect_uri
                      }
    post :token, request_params
    assert_response :success
    resp = JSON.parse(response.body).symbolize_keys
    assert_not_equal "aXsDTMH1cMx4G14TYfQMDuxBGeWjvP1OoaT9D70uP2zP9QMxMzQ0NjYzODE1", resp[:access_token]
    assert_equal "e22RFX9UHaKjHmqbF3J7Z5AV1eYlk21CczuAkgy3KuWhN5w4NVMxMzQ0NjYzODE1", resp[:refresh_token]
    assert_equal "Bearer", resp[:token_type]
    assert_equal 3600, resp[:expires_in]
  end
end
