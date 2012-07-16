module OAUTH2
  module Server
    module RequestMethods
      def authorize
      # render authorization page
      end

      # access_token, refresh_token
      def token

      end

      # register client
      def register

      end
    end

    module HelperMethods
      def create_oauth_client_request
        @oauth2_client_request = Oauth2::Request.new params
      end

      def verify_oauth2_client
        head :unauthorized unless @oauth2_client_request.client_valid?
      end

      def verify_oauth2_response_type
        render :nothing => true, :status => :bad_request unless @oauth2_client_request.response_type_valid?
      end
    end
  end
end
