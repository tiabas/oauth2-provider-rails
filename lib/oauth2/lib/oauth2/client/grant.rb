require 'uri'

module OAuth2
  module Grant
    class Base < Hash
      def self.new
          raise 'This is an abstract class'
      end

      def initialize(params)
          super(nil)
          self.merge!(params)
      end

      def to_www_form_urlencoded
          encoded_params = self.collect do |param_pair| 
              param_pair.map {|component| URI.encode_www_form_component(component) }.join("=")
          end
          param_string = encoded_params.join("&") 
      end
  
      def to_s
          self.to_www_form_urlencoded
      end
    end 

    class AuthorizationCode < Base
      def initialize(params)
        if params[:client_id].nil?
            raise "client_id must be provided"
        end
        params[:response_type] = 'code'
        super(params)
      end
    end

    class RefreshToken < Base
      def initialize(params)
          if params[:client_id].nil?
              raise "client_id must be provided"
          end
          params[:response_type] = 'token'
          super(params)
      end
    end

    class PasswordCredentials < Base
      def initialize(params)
          if not (params[:username] and params[:password])
              raise "username and  password must be provided"
          end
          params[:grant_type] = 'password' 
          super(params)
      end
    end

    class ClientCredentials < Base
      def initialize(params)
          default_params = { :grant_type => 'client_credentials' }
          params.merge!(default_params)
          super(params)
      end
    end
  end
end
