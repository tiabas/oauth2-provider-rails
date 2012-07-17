require 'uri'

module OAuth2
  module Client
    class Request
        AUTH_METHODS = {
            :authorization_code => OAuth2::Grant::AuthorizationCode ,
            :credentials => OAuth2::Grant::ClientCredentials,
            :password => OAuth2::Grant::Password,
            :refresh_token => OAuth2::Grant::RefreshToken
        }
        
        @@authorize_path = '/authorize'
        @@token_path = '/token'
        
        attr_reader :auth_type, :auth_params
        attr_accessor :scheme, :host, :port, :authorize_path, :token_path 
        
        def self.verified_scheme(scheme)
          raise "The scheme #{scheme} is not supported. Only http and https are supported" unless ['http', 'https'].include? scheme
          scheme
        end
        
        def initialize(auth_type, params, scheme, host, authorize_path=nil, token_path=nil, method="POST" port=80)
          @authorize_path = authorize_path || @@authorize_path
          @token_path = token_path || @@token_path
          @scheme = self.class.verified_scheme(scheme)
          @host = host
          @port = port
          @auth_type = auth_type
          @auth_params = AUTH_METHODS[auth_type].new(params)
        end
        
        def scheme=(scheme)
          @scheme = self.class.verified_scheme(scheme)
        end
        
        def authorization_uri
          query = auth_params.to_s
          URI::Generic.new(@scheme, nil, @host, nil, nil, @authorize_path, nil, query, nil).to_s
        end
        
        def access_token(uri, headers={})
            
        end  
    end 
  end           
end
