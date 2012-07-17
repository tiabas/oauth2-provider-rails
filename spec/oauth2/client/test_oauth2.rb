require_relative 'oauth2'
require 'net/http'
require 'test/unit'

class TestOAuth2Request < MiniTest::Unit::TestCase
    def test_request_as_empty_hash 
        r = OAUTH2::Grant::Base.new({})
        assert_equal(r, {})
    end
    
    def test_authorization_code_without_required_parameters
        assert_raises(RuntimeError) { OAUTH2::Grant::AuthorizationCode.new({}) }
    end
    
    def test_authorization_code_with_required_parameters
        r = OAUTH2::Grant::AuthorizationCode.new({ :response_type => 'code', :client_id => 's6BhdRkqt3' })
        assert_equal(r, { :response_type => 'code', :client_id => 's6BhdRkqt3' })
    end
    
    def test_authorization_code_to_string
        r = OAUTH2::Grant::AuthorizationCode.new({ :response_type => 'code', :client_id => 's6BhdRkqt3' })
        assert_equal(r.to_s, 'response_type=code&client_id=s6BhdRkqt3')
    end
    
    def test_creation_of_client_for_authorization_code_flow
        c = OAUTH2::Client.new(
                            :authorization_code, 
                            {:client_id => 's6BhdRkqt3', :state => 'xyz', :redirect_uri => 'http://client.example.com/oauth_v2/callback'},
                            'http', 
                            'server.example.com', 
                            authorize_path='/oauth_v2/authorize')
        assert_equal(c.authorization_uri, 'http://server.example.com/oauth_v2/authorize?client_id=s6BhdRkqt3&state=xyz&redirect_uri=http%3A%2F%2Fclient.example.com%2Foauth_v2%2Fcallback&response_type=code')
    end
    
    def test_creation_of_client_for_token_flow
        c = OAUTH2::Client.new(
                            :refresh_token, 
                            {:client_id => 's6BhdRkqt3', :state => 'xyz', :redirect_uri => 'http://client.example.com/oauth_v2/callback' },
                            'http', 
                            'server.example.com', 
                            authorize_path='/oauth_v2/authorize')
        assert_equal(c.authorization_uri, 'http://server.example.com/oauth_v2/authorize?client_id=s6BhdRkqt3&state=xyz&redirect_uri=http%3A%2F%2Fclient.example.com%2Foauth_v2%2Fcallback&response_type=token')
    end
    
    def test_creation_of_client_for_password_flow
        c = OAUTH2::Client.new(
                            :password, 
                            {:username => 'johndoe', :password => 'A3ddj3w'},
                            'http', 
                            'server.example.com', 
                            authorize_path='/oauth_v2/authorize')
        assert_equal(c.authorization_uri, 'http://server.example.com/oauth_v2/authorize?username=johndoe&password=A3ddj3w&grant_type=password')
    end
    
    def test_creation_of_client_for_credentials_flow
        c = OAUTH2::Client.new(
                            :credentials, 
                            {},
                            'http', 
                            'server.example.com', 
                            authorize_path='/oauth_v2/authorize')
        assert_equal(c.authorization_uri, 'http://server.example.com/oauth_v2/authorize?grant_type=client_credentials')
    end
    # def test_authorization_request_url
    #     params = {
    #         :response_type => 'code',
    #         :client_id => 's6BhdRkqt3',
    #         :redirect_uri => 'https://client.example.com/',
    #         :scope => 'scope',
    #         :state => 'xyz'
    #     }
    #     r = OAUTH2::Request.new('https://server.example.com/authorize', params)
    #     puts r.to_url
    # end
    # 
    # def test_access_token_request_url_with_correct_redirect_url
    #     params = {
    #         :grant_type => 'authorization_code',
    #         :code => 'SplxlOBeZQQYbYS6WxSbIA',
    #         :redirect_uri => 'https://client.example.com/'
    #     }
    #     OAUTH2::Request.new('https://server.example.com/authorize', params)
    # end
end