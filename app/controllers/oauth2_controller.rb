class Oauth2Controller < ApplicationController

  # request authorization
  def authorize
    handle_oauth_exception do
      @oa_request = OAuth2::Server::Request.new params.symbolize_keys
      handler = OAuth2::Server::RequestHandler.new(@oa_request)
      handler.verify_client_id
      @oa_pending_request = OauthPendingRequest.create!(@oa_request.to_hsh)
    end
  end

  #
  def process_authorization
    handle_oauth_exception do   
      pending_request = OauthPendingRequest.find_by_id params[:id]
      unless pending_request
        return render :nothing => true, :status => :bad_request
      end

      decision = params.fetch(:decision, false)
      unless decision == 'allow'
        err = OAuth2::OAuth2Error::AccessDenied.new "the user denied your request"
        return redirect_to err.redirect_uri(pending_request)
      end
      #!!possible bug may result here with the attributes call considering that scope
      #  should be space delimited strings
      #  pending_request.scope = params[:pending_request][:scope]
      unless pending_request.valid?
        return render :text => pending_request.errors.full_messages.join(' '), :status => :bad_request
      end

      @oa_request = OAuth2::Server::Request.new pending_request.attributes.symbolize_keys
      handler = OAuth2::Server::RequestHandler.new(@oa_request)

      if @oa_request.response_type? :token
        return redirect_to handler.access_token_redirect_uri(current_user)
      end

      return redirect_to handler.authorization_redirect_uri
    end
  end

  # access_token, refresh_token
  def token
    handle_oauth_exception do
      user = User.first
      @oa_request = OAuth2::Server::Request.new params.symbolize_keys
      handler = OAuth2::Server::RequestHandler.new(@oa_request)
      return render :json => handler.access_token_response(current_user)
    end
  end

  def register; end

  def process_registration

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
