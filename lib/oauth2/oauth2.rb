require "addressable/uri"

module OAUTH2
  class Request

    RESPONSE_TYPES = %w{ code token }
    GRANT_TYPES = %{ authorization_code password token client_credentials refresh_token }

    attr_reader :response_type, :client_id, :state, :scope, :authenticated, :errors
    private attr_writer :errors

    def initialize(opts={})
       @response_type = opts[:response_type]
       @client_id = opts[:client_id]
       @state = opts[:state]
       @grant_type = opts[:grant_type]
       @scope = opts[:scope]
       @username = opts[:username]
       @password = opts[:password]
       @redirect_uri = Addressable::URI.unencode opts[:redirect_uri]
       @errors = {}
    end

    def valid?
      return @authenticated unless @authenticated.nil?
      authenticate_client
    end
    
    def redirect_uri
      @redirect_uri  ||= (client_application ? client_application.redirect_uri : nil )
      unless redirect_uri_valid?
        raise InvalidRequest, errors[:redirect_uri].join(" ")
      end
      @redirect_uri
    end

    def authorization_redirect_uri(allow) 
      build_response_uri authorization_response
    end

    def token_response_redirect_uri(allow) 
      build_response_uri access_token_response
    end

  private

    def authorization_response
      params = {}
      params[:state] = state unless state.nil?
      params[:code] = generate_authorization_code
    end

    def access_token_response
      params = {}
      params[:refresh_token] = generate_refresh_token if response_type == "code"
      params.merge! access_token
    end

    def client_id_valid?
      validate_client_id
    end
    
    def client_application
      return @client_application unless @client_application.nil?
      validate_client_id
    end

    def build_response_uri(params={})
      uri = Addressable::URI.parse(redirect_uri)
      response_params = uri.query_values
      response_params.merge! params
      uri.query_values = response_params
      return uri
    end

    def authenticate_client
      @authenticated = begin
        case grant_type
          when "client_credentials"
            true if client_application.confidential?
            @errors[:credentials] << "Unauthorized client"
            false
          when "password" 
            true if user_credentials_valid?
            @errors[:credentials] << "Invalid username or password"
            false
          else
            true
        end
      end
    end

    def validate_client_id
      begin
        @client_application = Oauth2ClientApplication.find_by_client_id @client_id
      rescue
        @errors[:client_id] = "Client with id provided not found"
        false
      end
    end

    def validate_user_credentials
      return false unless (@username && @password)
      # User.check @username, @password
    end

    def validate_response_type
      return true if RESPONSE_TYPES.include? @response_type
      @errors[:response_type] = "Invalid response type"
      false
    end

    def validate_grant_type
      return true if GRANT_TYPES.include? @grant_type
      @errors[:grant_type] = "UnsupportedGrantType"
      false
    end

    def validate_scope(&block)
      raise "Fix Me"
    end

    def validate_redirect_uri
      errors[:redirect_uri] = []
      if @redirect_uri.nil?
        errors[:redirect_uri] << "Redirect uri is not valid. Provide and absolute URI"
      else
        uri = Addressable::URI.parse(@redirect_uri)
        unless ["http", "https"].include? uri.scheme
          errors[:redirect_uri] << "uri scheme is missing or unsupported"
        end
        unless uri.fragment.nil?
          errors[:redirect_uri] << "malformed uri must not include URI fragment"
        end
      end
      errors[:redirect_uri].any? ? false : true
    end

    def generate_authorization_code
      raise unless client_application
      client_application.generate_code 
    end

    def generate_request_token
      raise unless client_application
      client_application.generate_request_token 
    end

    def generate_access_token
      raise unless client_application
      client_application.generate_access_token
    end

    def generate_refresh_token
      raise unless client_application
      client_application.generate_refresh_token
    end
  end
end
