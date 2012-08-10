class Oauth2Controller < ApplicationController

  # before_filter :create_oauth_client_request, :only => [:authorize, :token]

  # request authorization
  def authorize
    @oa_request = OAuth2::Server::Request.new params.symbolize_keys
    handler = OAuth2::Server::RequestHandler.new(@oa_request, {
          :user_datastore => User,
          :client_datastore => OauthClientApplication,
          :token_datastore => OauthAccessToken,
          :code_datastore => OauthAuthorizationCode
          })
    handler.validate_client_id
    @oa_pending_request = OauthPendingRequest.create! @oa_request.to_hsh
  rescue Exception => e
    if e.is_a?(OAuth2::OAuth2Error::Error)
      if @oa_request.redirect_uri_valid?
        return redirect_to e.redirect_uri(@oa_request)
      end
      return render :text => e.to_txt, :status => :bad_request
    end
    raise
  end

  def process_authorization
    authorize = params.fetch(:commit, false)
    if authorize == 'deny'
      return redirect_to OAuth2::OAuth2Error::AccessDenied.new.redirect_uri, :status => :bad_request
    end
    
    pending_request = OauthPendingRequest.find_by_id params[:id]
    unless pending_request
      return render :nothing => true, :status => :bad_request
    end

    #! possible bug may result here with the attributes call
    pending_request.scope = params[:pending_request][:scope]
    unless pending_request.valid?
      return render :text => pending_request.errors.full_messages.join(' '), :status => :bad_request
    end

    oa_request = OAuth2::Server::Request.new pending_request.attributes.symbolize_keys
    handler = OAuth2::Server::RequestHandler.new(oa_request, {
              :user_datastore => User,
              :client_datastore => OauthClientApplication,
              :token_datastore => OauthAccessToken,
              :code_datastore => OauthAuthorizationCode
              })

    if oa_request.response_type? :token
      if params[:dialog] == 'true'
        @token = handler.fetch_access_token(current_user).to_hsh
        @redirect_to = oa_request.redirect_uri
        return render 'oauth2/dialog'
      end
      return handler.access_token_response(current_user).to_hsh, :status => :ok
    end

    redirect_to handler.authorization_redirect_uri, :status => :found
  rescue Exception => e
    unless e.is_a?(OAuth2::OAuth2Error::Error)
      raise e
    end
    return redirect_to e.redirect_uri(oa_request), :status => :bad_request
  end

  # access_token, refresh_token
  def token
    # @params:
    #  client_id     
    #  client_secret
    user = User.first
    oa_request = OAuth2::Server::Request.new params.symbolize_keys
    handler = OAuth2::Server::RequestHandler.new(oa_request, {
              :user_datastore => User,
              :client_datastore => OauthClientApplication,
              :token_datastore => OauthAccessToken,
              :code_datastore => OauthAuthorizationCode
              })
    render :json => handler.access_token_response(user).to_hsh, :status => :ok
  rescue Exception => e
    unless e.is_a?(OAuth2::OAuth2Error::Error)
      raise e
    end
    if oa_request.redirect_uri_valid?
      return redirect_to e.redirect_uri(oa_request), :status => :bad_request
    end
    render :text => e.to_txt, :status => :bad_request
  end

  def register

  end

  def process_registration

  end

end
