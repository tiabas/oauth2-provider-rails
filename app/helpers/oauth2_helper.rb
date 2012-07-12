module Oauth2Helper

	def create_oauth_client_request
		@oauth2_client_request = Oauth2::Request.new params
	end

	def verify_oauth2_response_type
		# @oauth2_response_type = params.fetch(:response_type, nil)
		# valid_type = @oauth2_client_request.response_type_valid?
		render :nothing => true, :status => :bad_request unless @oauth2_client_request.response_type_valid?
	end

	def verify_oauth2_client_id
		# result = Oauth2::Request.verify_client_id(params.fetch(:client_id, ""))
		# { :client => Oauth2ClientApplication, :errors => ["client id not found"]}
		# render :nothing => true, :status => :unauthorized if result.errors.any?
		# @oauth2_client = result(:client)
		# client = Oauth2ClientApplication.find_by_client_id params.fetch(:client_id, nil)
		render :nothing => true, :status => :unauthorized unless @oauth2_client_request.client_id_valid?
	end
end
