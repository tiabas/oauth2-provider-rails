require 'request'
module OAuth2
    module HelperMethods
      def create_oauth_client_request
        @oauth2_client_request = Oauth2::Server::Request.new params
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