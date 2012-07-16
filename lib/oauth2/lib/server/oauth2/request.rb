require 'addressable/uri'

module OAuth2
  module Server
    class Request

      RESPONSE_TYPES = [ :code, :token ]
      GRANT_TYPES = [ :authorization_code, :password, :client_credentials :refresh_token ]

      attr_reader :response_type, :grant_type, :client_id, :client_secret, :state, :scope, 
                  :errors

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
        @code          = opts[:code]
        @username      = opts[:username]
        @password      = opts[:password]
        @errors        = {}
        @validated     = nil
      end

      def client_application
        @client_application || validate_client_credentials
      end

      def client_valid?
        !!client_application
      end

      def grant_type_valid?
        !!validate_grant_type
      rescue OAUTH2Error::InvalidRequest => e
        false
      end

      def response_type_valid?
        !!validate_response_type
      rescue OAUTH2Error::InvalidRequest => e
        false
      end

      def redirect_uri
        validate_redirect_uri
      end

      def authorization_code
        # 
        validate()
        unless @response_type.to_sym == :code
          raise OAUTH2Error::UnsupportedResponseType, "The response type, #{@response_type}, is not valid for this request"
        end
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
        #   :expires_in => 3600,
        #   :refresh_token => "tGzv3JOkF0XG5Qx2TlKWIA",
        # }
        validate()
        unless (@grant_type || @response_type.to_sym == :token)
          raise OAUTH2Error::InvalidRequest, "The grant type or response type provided is not valid"
        end
        generate_access_token.to_hash
      end

      def access_token_redirect_uri
        # http://example.com/cb#access_token=2YotnFZFEjr1zCsicMWpAA&state=xyz&token_type=example&expires_in=3600
        build_response_uri :fragment_params => access_token
      end
      
    private

      def build_response_uri(query_params={}, fragment_params=nil)
        uri = Addressable::URI.parse redirect_uri
        uri.query_values = Addressable::URI.form_encode query_params unless query_params.nil?
        uri.fragment = Addressable::URI.form_encode fragment_params unless fragment_params.nil?
        return uri
      end

      def validate
        return unless @validated.nil?
        # REQUIRED: Check that client_id and client_secret are valid
        validate_client_credentials

        # REQUIRED: Either response_type or grant_type  
        if response_type.nil? && grant_type.nil?
          raise OAUTH2Error::InvalidRequest, "Missing parameters: response_type or grant_type"
        end

        # validate response_type if given
        validate_response_type unless @response_type.nil?

        # validate grant_type if given
        validate_grant_type unless @grant_type.nil?

        # validate redirect uri if given grant_type is authorization_code or response_type is token
        if @response_type.to_sym == :token || @grant_type.to_sym == :authorization_code
          validate_redirect_uri
        end

        if @grant_type.to_sym == :authorization_code
          validate_authorization_code
        end

        # cache validation result
        @validated = true
      end

      def validate_authorization_code
        if @code.nil?
          raise OAUTH2Error::InvalidRequest, "Missing parameters: code"
        end
        unless verify_authorization_code
          raise OAUTH2Error::UnauthorizedClient, "Authorization code provided did not match client"
        end
        @code
      end

      def validate_client_credentials
        if @client_id.nil? && @client_secret.nil?
          @errors[:client] = []
          @errors[:client] << "client_id" if @client_id.nil?
          @errors[:client] << "client_secret" if @client_secret.nil?
          raise OAUTH2Error::InvalidRequest, "Missing parameters: #{@errors[:client].join(", ")}"
        end
        @client_application = Oauth2ClientApplication.where(
                              :client_id     => @client_id,
                              :client_secret => @client_secret
                              ).first!
      rescue ActiveRecord::RecordNotFound
        @errors[:client] = "Unauthorized Client"
        raise OAUTH2Error::UnauthorizedClient, @errors[:client] 
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
        return RESPONSE_TYPES.include? @response_type.to_sym
        @errors[:response_type] = "Invalid response type"
        raise OAUTH2Error::UnsupportedResponseType
      end

      def validate_grant_type
        return GRANT_TYPES.include? @grant_type.to_sym
        @errors[:grant_type] = "Unsupported grant type"
        raise OAUTH2Error::UnsupportedGrantType
      end

      def validate_scope
        # FIX ME!!
        @errors[:scope] = "InvalidScope"
        raise OAUTH2Error::InvalidScope, "FIX ME!!!!!!"
      end

      def validate_redirect_uri
        return if @redirect_uri.nil?
        
        errors[:redirect_uri] = []

        uri = Addressable::URI.parse(@redirect_uri)
        unless uri.scheme == "https" 
            errors[:redirect_uri] << "URI scheme is unsupported"
        end
        unless uri.fragment.nil?
            errors[:redirect_uri] << "URI should not include URI fragment"
        end
        unless uri.query.nil?
            errors[:redirect_uri] << "URI should not include query string"
        end

        return @redirect_uri if client_application.redirect_uri == @redirect_uri && !errors[:redirect_uri].any?
        raise OAUTH2Error::InvalidRequest, errors[:redirect_uri].join(", ")
      end

      def verify_authorization_code
        client_application.verify_code(@code)
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
