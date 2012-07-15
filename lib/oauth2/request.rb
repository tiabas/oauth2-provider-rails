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
        @response_type = opts[:response_type]
        @grant_type    = opts[:grant_type]
        @client_id     = opts[:client_id]
        @client_secret = opts[:client_secret]
        @state         = opts[:state]
        @scope         = opts[:scope]
        @username      = opts[:username]
        @password      = opts[:password]
        @redirect_uri  = opts[:redirect_uri]
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

      def authorization_redirect_uri(allow) 
        build_response_uri authorization_response
      end

      def token_response_redirect_uri(allow) 
        build_response_uri access_token_response
      end
      
    private
    
      def missing?(*values)
        values.inject(true) {|a, b| a && b.nil? }
      end

      def authorization_response
        params = {}
        params[:state] = state unless state.nil?
        params[:code] = generate_authorization_code 
      end

      def access_token_response
        client_valid? && grant_type_valid?
        params = {}
        params[:access_token] = generate_access_token if response_type == :code
        params.merge! access_token
      end

      def refresh_token_response
        raise unless (client_valid? && grant_type_valid?)
        raise if grant_type != :refresh
        params = {}
        params[:refresh_token] = generate_refresh_token
        params.merge! access_token
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
        return GRANT_TYPES.include? @grant_type || response_type == :token
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

      def generate_request_token
        client_application.generate_request_token 
      end

      def generate_access_token
        client_application.generate_access_token
      end

      def generate_refresh_token
        client_application.generate_refresh_token
      end
    end
  end
end
