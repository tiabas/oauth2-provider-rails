require 'mocha'
require 'minitest/unit'
require 'json'

class TestOAuth2Request < MiniTest::Unit::TestCase
  
  before(:all) do
    @code = 'G3Y6jU3a'
    @client_id = 's6BhdRkqt3'
    @client_secret = 'SplxlOBeZQQYbYS6WxSbIA'
    @access_token = '2YotnFZFEjr1zCsicMWpAA'
    @refresh_token = 'tGzv3JOkF0XG5Qx2TlKWIA'
    @expires_in = 3600
    @token_type = 'Bearer'
    @token_response = {
                        :access_token => @access_token,
                        :refresh_token => @refresh_token
                        :token_type => @token_type,
                        :expires_in =>  @expires_in,
                      }
  end
  
  def test_authorization_code_grant_authorization_request
    c = OAUTH2::Server::Request.new({
                        :client_id => @client_id,
                        :response_type => 'code',
                        :redirect_uri => 'http://client.example.com/oauth_v2/cb',
                        :state => 'xyz'
                        })
    redirect_uri = "http://client.example.com/oauth_v2/cb?code=#{@code}&state=xyz"
    assert_equal redirect_uri, c.authorization_redirect_uri 
  end

  def test_authorization_code_grant_should_return_access_token
    c = OAUTH2::Server::Request.new({
                        :client_id => @client_id,
                        :grant_type => 'authorization_code',
                        :code => @code
                        })
    assert_equal @token_response, JSON.parse(c.access_token)
  end
  
  def test_implicit_grant_authorization_request_should_return_access_token
    c = OAUTH2::Server::Request.new({
                        :client_id => @client_id,
                        :response_type => 'token',
                        :redirect_uri => 'http://client.example.com/oauth_v2/cb',
                        :state => 'xyz',
                        })
    # should stub request#access_token
    redirect_uri = 'http://example.com/cb#access_token=2YotnFZFEjr1zCsicMWpAA&state=xyz&token_type=example&expires_in=3600'
    assert_equal redirect_uri, c.access_token_redirect_uri
  end

  def test_resource_owner_credentials_should_return_access_token
    c = OAUTH2::Server::Request.new({
                        :client_id => @client_id,
                        :grant_type => 'password',
                        :username => 'johndoe',
                        :password => 'A3ddj3w'
                        })
    # should stub request#access_token
    assert_equal @token_response, JSON.parse(c.access_token)
  end
  
  def test_client_credentials_should_return_access_token
    c = OAUTH2::Server::Request.new({
                        :client_id => @client_id,
                        :client_secret => @client_secret,
                        :grant_type => 'client_credentials'
                        })
    # should stub request#access_token
    assert_equal @token_response, JSON.parse(c.access_token)
  end

  def test_refresh_token_request_should_return_access_token
    c = OAUTH2::Server::Request.new({
                        :client_id => @client_id,
                        :grant_type => 'refresh_token',
                        :refresh_token => @refresh_token
                        })
    # should stub request#access_token
    assert_equal @token_response, JSON.parse(c.access_token)
  end
end