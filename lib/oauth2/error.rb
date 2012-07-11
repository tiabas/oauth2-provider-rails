module OAUTH2
  class InvalidClient < StandardError;end
  class InvalidRequest < StandardError;end
  class InvalidScope < StandardError;end
  class InvalidGrant < StandardError;end
  class AccessDenied < StandardError;end
  class UnsupportedResponseType < StandardError;end
  class UnsupportedGrantType < StandardError;end
  class UnauthorizedClient < StandardError;end

	class OAuth2Error < StandardError

	end
end