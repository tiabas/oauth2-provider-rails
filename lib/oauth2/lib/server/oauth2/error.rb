module OAuth2
  module OAuth2Error
    class Error < StandardError
      attr_reader :response, :code, :description

      def self.new
        raise "#{ self.class.to_s} is an abstract class!"
      end
      # standard error values include:
      # :invalid_request, :invalid_client, :invalid_token, :invalid_grant, :unsupported_grant_type, :invalid_scope
      # :invalid_grant_type, :unauthorized_client
      def initialize(msg)
        message = ["OAuth Error #{ self.class.to_s} "]
        message << msg 

        super(message.join(","))
      end
    end

    class InvalidClient < Error; end
    class InvalidRequest < Error; end
    class InvalidScope < Error; end
    class InvalidGrant < Error; end
    class AccessDenied < Error; end
    class UnsupportedResponseType < Error; end
    class UnsupportedGrantType < Error; end
    class UnauthorizedClient < Error; end
    class ServerError < Error; end
    class TemporarilyUnavailable < Error; end
  end
end