require 'uri'
require 'net/http'

module OAUTH2
    module AuthorizationGrant
        module Base < Hash
            def initialize(params)
                super(nil)
                self.merge!(params)
            end

            def to_www_form_urlencoded
                encoded_params = self.collect do |param_pair| 
                    param_pair.map {|component| URI.encode_www_form_component(component) }.join("=")
                end
                param_string = encoded_params.join("&") 
            end
        
            def to_s
                self.to_www_form_urlencoded
            end
        end 
    
        class AuthorizationCode < Base
            def initialize(params)
                if params[:client_id].nil?
                    raise "client_id must be provided"
                end
                params[:response_type] = 'code'
                super(params)
            end
        end
    
        class RefreshToken < Base
            def initialize(params)
                if params[:client_id].nil?
                    raise "client_id must be provided"
                end
                params[:response_type] = 'token'
                super(params)
            end
        end
    
        class PasswordCredentials < Base
            def initialize(params)
                if not (params[:username] and params[:password])
                    raise "username and  password must be provided"
                end
                params[:grant_type] = 'password' 
                super(params)
            end
        end
    
        class ClientCredentials < Base
            def initialize(params)
                default_params = { :grant_type => 'client_credentials' }
                params.merge!(default_params)
                super(params)
            end
        end
    end

    class Client
        
        AUTH_METHODS = {
            :authorization_code => OAUTH2::Grant::AuthorizationCode ,
            :credentials => OAUTH2::Grant::ClientCredentials,
            :password => OAUTH2::Grant::Password,
            :refresh_token => OAUTH2::Grant::RefreshToken
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
