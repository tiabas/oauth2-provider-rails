module OAUTH2
  module OAuth2Error
    class OAuth2Error < StandardError
      attr_reader :response, :code, :description

      # standard error values include:
      # :invalid_request, :invalid_client, :invalid_token, :invalid_grant, :unsupported_grant_type, :invalid_scope
      # :invalid_grant_type, :unauthorized_client
      def initialize(msg)
        message = ["OAuth2 Error: ", self.class.to_s]
        message << msg 

        super(message.join(""))
      end
    end

    class InvalidClient < OAuth2Error; end
    class InvalidRequest < OAuth2Error; end
    class InvalidScope < OAuth2Error; end
    class InvalidGrant < OAuth2Error; end
    class AccessDenied < OAuth2Error; end
    class UnsupportedResponseType < OAuth2Error; end
    class UnsupportedGrantType < OAuth2Error; end
    class UnauthorizedClient < OAuth2Error; end
  end
end