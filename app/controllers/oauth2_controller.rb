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
    handler.verify_client_id
    @oa_pending_request = OauthPendingRequest.create! @oa_request.to_hsh
  rescue Exception => e
    if e.is_a?(OAuth2::OAuth2Error::Error)
      unless @oa_request.redirect_uri_valid?
        return render :text => "The client provided invalid uri"
      end
      return redirect_to e.redirect_uri(@oa_request)
    end
    raise
  end

  def process_authorization    
    pending_request = OauthPendingRequest.find_by_id params[:id]
    unless pending_request
      return render :nothing => true, :status => :bad_request
    end

    decision = params.fetch(:commit, false)
    if decision == 'deny'
      err = OAuth2::OAuth2Error::AccessDenied.new "the user denied your request"
      return redirect_to err.redirect_uri(pending_request)
    end
    #! possible bug may result here with the attributes call
    # pending_request.scope = params[:pending_request][:scope]
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

    return redirect_to handler.access_token_redirect_uri(current_user) if oa_request.response_type? :token

    return redirect_to handler.authorization_redirect_uri
  rescue Exception => e
    unless e.is_a?(OAuth2::OAuth2Error::Error)
      raise e
    end
    return redirect_to e.redirect_uri(oa_request)
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
    return render :json => handler.access_token_response(current_user)
  rescue Exception => e
    unless e.is_a?(OAuth2::OAuth2Error::Error)
      raise e
    end
    if oa_request.redirect_uri_valid?
      return redirect_to e.redirect_uri(oa_request)
    end
    render :text => e.to_txt, :status => :bad_request
  end

  def register

  end

  def process_registration

  end  
end
