module OAUTH2
  module Server
    module AccessToken
    	module InstanceMethods

      # generate token
      def generate_token

      end
      
      # generate refresh token
      def generate_refresh_token

      end

      # to_hsh
      def to_hsh
      	{
      		:token => token,
      		:token_type => token_type,
      		:expires_in => expires_in,
      		:refresh_token => refresh_token
      	}
      end
    end
  end
end