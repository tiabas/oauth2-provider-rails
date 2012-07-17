module OAuth2
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
        wrap_unauthorized unless @oauth2_client_request.client_valid?
      end

      def verify_oauth2_response_type
        render :nothing => true, :status => :bad_request unless @oauth2_client_request.response_type_valid?
      end

      protected
      def wrap_unauthorized
        response.headers['WWW-Authenticate'] = 'WRAP'
        render :layout => false, :status => :unauthorized, :text => "Unauthorized"
      end

      def wrap_forbidden
        response.headers['WWW-Authenticate'] = 'WRAP'
        render :layout => false, :status => :forbidden, :text => "Forbidden"
      end
    end
  end
end
