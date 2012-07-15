require "addressable/uri"

module OAUTH2
  module Server
    class Request

      RESPONSE_TYPES = [ :code, :token ]
      GRANT_TYPES = [ :authorization_code, :password, :client_credentials :refresh_token ]

      attr_reader :response_type, :grant_type, :client_id, :client_secret, :state, :scope, 
                  :authenticated, :errors

      def self.from_http_request
        # create request from http headers
      end

      def initialize(opts={})
        @client_id     = opts[:client_id]
        @client_secret = opts[:client_secret]
        @redirect_uri  = opts[:redirect_uri]
        @response_type = opts[:response_type]
        @grant_type    = opts[:grant_type]
        @state         = opts[:state]
        @scope         = opts[:scope]
        @username      = opts[:username]
        @password      = opts[:password]
        @errors        = {}
      end

      def client_application
        @client_application || validate_client_credentials
      end

      def client_valid?
        !!client_application
      end

      def grant_type_valid?
        validate_grant_type
      end

      def redirect_uri
        validate_redirect_uri
      end

      def authorization_code
        # 
        client_valid? && response_type_valid?
        generate_authorization_code
      end

      def authorization_response
        # {
        #   :code => "2YotnFZFEjr1zCsicMWpAA", 
        #   :state => "auth",
        # }
        response = { 
          :code => authorization_code
        }
        response[:state] = state unless state.nil?
        response 
      end

      def authorization_redirect_uri(allow=false) 
        # https://client.example.com/cb?code=SplxlOBeZQQYbYS6WxSbIA&state=xyz
        build_response_uri authorization_response
      end

      def access_token
        # {
        #   :access_token => "2YotnFZFEjr1zCsicMWpAA", 
        #   :token_type => "bearer",
        #   :expires_in => 31536000,
        #   :refresh_token => "tGzv3JOkF0XG5Qx2TlKWIA",
        # }
        client_valid? && (grant_type_valid? || response_type_valid?)
        generate_access_token.to_hash
      end

      def access_token_redirect_uri
        # http://example.com/cb#access_token=2YotnFZFEjr1zCsicMWpAA&state=xyz&token_type=example&expires_in=3600
        build_response_uri access_token_response
      end
      
    private
    
      def missing?(*values)
        values.inject(true) {|a, b| a && b.nil? }
      end

      def refresh_token_response
        client_valid? && grant_type_valid?
        if grant_type != :refresh
          raise OAUTH2Error::InvalidRequest, "grant_type is missing or unsupported"
        end
        {
          :refresh_token => generate_refresh_token
        }
      end

      def build_response_uri(params={})
        uri = redirect_uri
        response_params = uri.query_values
        response_params.merge! params
        uri.query_values = response_params
        return uri
      end

      def validate_client_credentials
        if @client_id.nil? && @client_secret.nil?
          errs = ["Missing parameters: "]
          errs << "client_id" if @client_id.nil?
          errs << "client_secret" if @client_id.nil?
          @errors[:client] = errs.join(" ")
          raise OAUTH2Error::InvalidRequest, @errors[:client]
        end
        @client_application = Oauth2ClientApplication.where(
                              :client_id     => @client_id,
                              :client_secret => @client_secret
                              ).first!
      rescue ActiveRecord::RecordNotFound
         @errors[:client] = "Unauthorized Client"
        raise OAUTH2Error::UnauthorizedClient
      end

      def validate_user_credentials
        unless @username && @password
          # throw error
        end
        user = User.authenticate @username, @password
        return user unless user.nil?
        @errors[:credentials] = "Invalid username or password"
        raise OAUTH2Error::AccessDenied
      end

      def validate_response_type
        return RESPONSE_TYPES.include? @response_type
        @errors[:response_type] = "Invalid response type"
        raise OAUTH2Error::UnsupportedResponseType
      end

      def validate_grant_type
        return GRANT_TYPES.include? @grant_type
        @errors[:grant_type] = "Unsupported grant type"
        raise OAUTH2Error::UnsupportedGrantType
      end

      def validate_scope(&block)
        # FIX ME!!
        @errors[:scope] = "InvalidScope"
        raise OAUTH2Error::InvalidScope
      end

      def validate_redirect_uri
        errors[:redirect_uri] = []
        if @redirect_uri.nil?
            errors[:redirect_uri] << "Redirect uri is not valid. Provide and absolute URI"
        else
            uri = Addressable::URI.parse(@redirect_uri)
            unless uri.scheme == "https" 
                errors[:redirect_uri] << "uri scheme is unsupported"
            end
            unless uri.fragment.nil?
                errors[:redirect_uri] << "malformed uri must not include URI fragment"
            end
        end
        return @redirect_uri if client_application.redirect_uri == @redirect_uri && !errors[:redirect_uri].any?
        raise OAUTH2Error::InvalidRequest, errors[:redirect_uri].join(" ")
      end

      def generate_authorization_code
        client_application.generate_code 
      end

      def generate_access_token
        client_application.generate_access_token
      end
    end
  end
end
