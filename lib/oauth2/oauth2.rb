require "addressable/uri"

module OAUTH2

  class InvalidRequest < StandardError
    def initialize(msg = "You've triggered a MyError")
      super(msg)
    end
  end
  
  class Request
    
    RESPONSE_TYPES = %w{ code token }
    REDIRECT_URI_REGEX = /^((http|https):\/\/)[\w\d\.\/]+\.([a-z]+)/

    attr_reader :response_type, :client_id, :state, :scope
    private attr_accessor :errors
    def initialize(opts={})
       @response_type = opts[:response_type]
       @client_id = opts[:client_id]
       @state = opts[:state]
       @scope = opts[:scope]
       @redirect_uri = opts[:redirect_uri]
       @errors = {}
    end

    def redirect_uri
      @redirect_uri || (client_application ? client_application.redirect_uri : nil )
    end

    def client_id_valid?
      validate_client_id
    end

    def response_type_valid?
      validate_response_type
    end

    def redirect_uri_valid? 
      validate_redirect_uri
    end

    def authorization_redirect_uri
      unless redirect_uri_valid?
        raise InvalidURIError, errors[:invalid_request].join " "
      end
      uri = Addressable::URI.parse(@redirect_uri)
      params = uri.query_values
      params[:code] = generate_authorization_code if response_type == "code"
      params[:token] = generate_request_token if response_type == "token"
      params[:state] = state unless state.nil?
      uri.query_values = params
      return uri
    end

  private
    
    def validate_client_id
      begin
        @client_application = Oauth2ClientApplication.find_by_client_id @client_id
      rescue
        @errors[:client_id] = "Client with id provided not found"
        false
      end
    end

    def validate_redirect_uri
      errors[:invalid_request] = []
      if redirect_uri.nil?
        errors[:invalid_request] << "Redirect uri is not valid. Provide and absolute URI"
      else
        uri = Addressable::URI.parse(@redirect_uri)
        unless ["http", "https"].include? uri.scheme
          errors[:invalid_request] << "uri scheme is missing or unsupported"
        end
        unless uri.fragment.nil?
          errors[:invalid_request] << "malformed uri must not include URI fragment"
        end
      end
      errors[:invalid_request].any? ? false : true
    end

    def validate_response_type
      return true if RESPONSE_TYPES.include? @response_type
      @errors[:response_type] = "Invalid response type"
      false
    end

    def client_application
      return @client_application unless @client_application.nil?
      validate_client_id
    end

    def generate_authorization_code
      raise unless client_application
      client_application.generate_code 
    end

    def generate_request_token
      raise unless client_application
      client_application.generate_request_token 
    end
  end
end
