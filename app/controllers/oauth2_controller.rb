class Oauth2Controller < ApplicationController
  # Authorization Endpoint
  # This is the endpoint that would be used for the Implicit grant flow
  # NOTE: Facebook does this but, you should NEVER EVER send the request
  # parameters back to the client. It is a DUMB move!
  def authorize
    handle_oauth_exception do
      @oa_request = OAuth2::Server::Request.new params.symbolize_keys
      handler = OAuth2::Server::RequestHandler.new(@oa_request)
       @app = handler.client_application
      unless params.fetch(:approval_prompt, true)
        if @oa_request.response_type?(:token)
          return redirect_to handler.access_token_redirect_uri(current_user)
        elsif @oa_request.response_type?(:code)
          return redirect_to handler.authorization_redirect_uri(current_user)
        end
        raise OAuth2::OAuth2Error::Error.new("Invalid response type #{@oa_request.response_type}")
      end
      @pending_auth_request = PendingAuthorizationRequest.from_request_params(@oa_request.to_hash)
      @pending_auth_request.user = current_user
      @pending_auth_request.save!
    end
  end

  # 
  def process_authorization
    handle_oauth_exception do
      pending_request = PendingAuthorizationRequest.find_by_signature_and_user_id(params[:signature], current_user.id)
      unless pending_request
        return render :nothing => true, :status => :bad_request
      end

      unless params.fetch(:allow_access, false)
        err = OAuth2::OAuth2Error::AccessDenied.new "the user denied your request"
        return redirect_to err.redirect_uri(pending_request)
      end
      #!!possible bug may result here with the attributes call considering that scope
      #  should be space delimited strings
      # pending_request.scope = params[:pending_request][:scope]
      # unless pending_request.save
      #   return render :text => pending_request.errors.full_messages.join(' '), :status => :bad_request
      # end

      @oa_request = OAuth2::Server::Request.new(pending_request.attributes.symbolize_keys)
      handler = OAuth2::Server::RequestHandler.new(@oa_request)

      if @oa_request.response_type? :token
        return redirect_to handler.access_token_redirect_uri(current_user)
      end

      return redirect_to handler.authorization_redirect_uri(current_user)
    end
  end

  # access_token, refresh_token
  def token
    handle_oauth_exception do
      @oa_request = OAuth2::Server::Request.new params.symbolize_keys
      handler = OAuth2::Server::RequestHandler.new(@oa_request)
      return render :json => handler.access_token_response(current_user)
    end
  end

private

  def handle_oauth_exception(&block)
    yield
  rescue Exception => e
    if e.is_a?(OAuth2::OAuth2Error::Error)
      if @oa_request.redirect_uri_valid?
        return redirect_to e.redirect_uri(@oa_request)
      end
      return render :text => "the client provided an invalid redirect URI"
    end
    raise e
  end
end
