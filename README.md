# OAuth2 Server Side Demo 
This is a demo rails application that shows how to use the oauth2-ruby gem to create an oauth2 implementation on the server side. It
requires that you have the oauth2-ruby gem installed. 
* [oauth2-ruby source on Github][code]

[code]: https://github.com/tiabas/oauth2-ruby

## Error Handling
All controller actions are wrapped in block that authomatically takes care of authorization and authentication error responses. This is included 
as an example. Your milage may vary however, exception handling could be done in a similar fashion.

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

## Implicit Grant Flow

The implicit grant type is used to obtain access tokens and is optimized for public clients known to operate a
particular redirection URI. This flow may be handled in two ways depending on the value of the response_type 
in the client http request.

If the response_type value is 'code' the client will have to make separate requests for authorization and access token,
the client receives the access token as the result of the authorization request.

The implicit grant type does not include client authentication, and relies on the presence of the resource owner and the registration 
of the redirection URI. The access token is encoded into the redirection URI and it may be exposed to the resource owner and other
applications residing on the same device.

The oauth2-ruby gem abstracts the logic needed to handle this flow. The following steps 

## Step 1
A client initiates the flow by directing the resource owner's user-agent to the authorization endpoint. This endpoint is handled by the 
authorize action within your oauth controller class. The request parameters are stored as a pending request object and are not sent back
to the user-agent

    # Client request to authorization server
    POST /oauth2/token HTTP/1.1
    Host: authorization.server.com
    Content-Type: application/x-www-form-urlencoded

    client_id={client_id}&
    redirect_uri=https://client.server.example.com/code&
    response_type=code&
    state=xyz

    # Authorization Endpoint
    # This is the endpoint that would be used for the Implicit grant flow
    def authorize
      handle_oauth_exception do
        @oa_request = OAuth2::Server::Request.new params.symbolize_keys
        handler = OAuth2::Server::RequestHandler.new(@oa_request)
         @app = handler.client_application
        unless params.fetch(:approval_prompt, false)
          if @oa_request.response_type? :token
            return redirect_to handler.access_token_redirect_uri(@user)
          end

          return redirect_to handler.authorization_redirect_uri(@user)
        end
        @oa_pending_request = OauthPendingRequest.create!(@oa_request.to_hsh)
      end
    end

## Step 2
The action will render a form requesting the user to either allow or deny the request

    <%= form_for(@oa_pending_request, :url => oauth2_process_authorization_path(:id => @oa_pending_request.id), :method => :post) do |request_form|-%>
      <section>
        <header><h1>Example app</h1></header>
        <div> The application "Example Client" would like to access your profile. Would you like to give "Example Client" access?
        <%= submit_tag :allow, :name => 'decision' %>
        <%= submit_tag :deny, :name => 'decision' %>
      </section>
    <% end -%>


When the user submits the form, the data is posted to the 'process_authorization' action of the oauth controller. If the user denies the request, the 
user-agent is redirected to the callback URL with the error code and error description as parameters. Otherwise, the request parameters are loaded from
the pending request that was created in the pre-authorization step and used to create a new request handler. Assuming all goes well, if the response type
was 'token' the access token can be retrieved from the request handler and returned either in the URL query component or the body of the response. If the
response type was 'code', the authorization code is returned in the query component of the authorization redirect URI.

    def process_authorization
      handle_oauth_exception do

        decision = params.fetch(:decision, false)
        unless decision == 'allow'
          err = OAuth2::OAuth2Error::AccessDenied.new "the user denied your request"
          return redirect_to err.redirect_uri(pending_request)
        end

        pending_request = OauthPendingRequest.find_by_id params[:id]
        unless pending_request
          return render :nothing => true, :status => :bad_request
        end

        pending_request.scope = params[:pending_request][:scope]
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

A successful response look similar to the one below:
    
    { 
      "code": "O0RfagVSxCn6svUlxLQvSNSpCCnImfMv2zifYDPZXO19wiPYxMzQ1MDEzNzU3",
      "state": "xyz"
    }


## Step 3
After the application receives the authorization code, it may exchange the authorization code for an access token and a refresh token. A request needs
to be made to the token endpoint. The request will need to include the client id, authorization code and optionally, the redirect URI. The host name in
the redirect URI, if included, must match that which was used when registering the client application.

    POST /oauth2/token HTTP/1.1
    Host: authorization.server.com
    Content-Type: application/x-www-form-urlencoded

    code=4/v6xr77ewYqhvHSyW6UJ1w7jKwAzu&
    client_id={client_id}&
    client_secret={client_secret}&
    redirect_uri=https://client.server.example.com/oauth2_callback&
    grant_type=authorization_code&
    state=xyz

The above request will be handle by the "token" action in the oauth2 controller:

    def token
      handle_oauth_exception do
        @oa_request = OAuth2::Server::Request.new params.symbolize_keys
        handler = OAuth2::Server::RequestHandler.new(@oa_request)
        return render :json => handler.access_token_response(current_user)
      end
    end

A successful response will include: access_token, refresh_token, expires_in, token_type. If the state parameter was included in the request, it will also
be included in the response

    { 
      "access_token": "PZGRzqCZhuc4dGsBNO6hEkHCNFvx2HfqrIgcGJifHilPDQGpNwxMzQ1MDE0NDQ2",
      "token_type": "Bearer",
      "expires_in": 3600,
      "refresh_token": "QUpDsfIg2mCTe5taePulQyfJi8QLk3rdUBEGPrpqGPKSfKocUxMzQ1MDE0NDQ2",
      "state": "xyz"
    }


## Client Credentials

Request:

    POST /oauth2/token HTTP/1.1
    Host: authorization.server.com
    Content-Type: application/x-www-form-urlencoded

    client_id={client_id}&
    client_secret={client_secret}&
    redirect_uri=https://client.server.example.com/oauth2_callback&
    grant_type=client_credentials&
    state=xyz

Response:

    {
      "access_token": "PZGRzqCZhuc4dGsBNO6hEkHCNFvx2HfqrIgcGJifHilPDQGpNwxMzQ1MDE0NDQ2",
      "token_type": "Bearer",
      "expires_in": 3600,
      "refresh_token": "QUpDsfIg2mCTe5taePulQyfJi8QLk3rdUBEGPrpqGPKSfKocUxMzQ1MDE0NDQ2",
      "state": "xyz"
    }


## Password

Request:

    POST /oauth2/token HTTP/1.1
    Host: authorization.server.com
    Content-Type: application/x-www-form-urlencoded

    client_id={client_id}&
    username={username}&
    password={password}&
    redirect_uri=https://client.server.example.com/oauth2_callback&
    grant_type=password&
    state=xyz

Response:

    {
      "access_token": "PZGRzqCZhuc4dGsBNO6hEkHCNFvx2HfqrIgcGJifHilPDQGpNwxMzQ1MDE0NDQ2",
      "token_type": "Bearer",
      "expires_in": 3600,
      "refresh_token": "QUpDsfIg2mCTe5taePulQyfJi8QLk3rdUBEGPrpqGPKSfKocUxMzQ1MDE0NDQ2",
      "state": "xyz"
    }


## Refresh Token
A new access token may be obtain by hitting the token endpoint. To obtain a new access token, an HTTPs POST such as the one below is made. These requests must include the following parameters: client_id, refresh_token, grant_type

    POST /oauth2/token HTTP/1.1
    Host: authorization.server.com
    Content-Type: application/x-www-form-urlencoded

    client_id={client_id}&
    client_secret={client_secret}&
    refresh_token=QUpDsfIg2mCTe5taePulQyfJi8QLk3rdUBEGPrpqGPKSfKocUxMzQ1MDE0NDQ2&
    redirect_uri=https://client.server.example.com/oauth2_callback&
    grant_type=refresh_token

 A response from the request above is shown below:

    {
      "access_token": "PZGRzqCZhuc4dGsBNO6hEkHCNFvx2HfqrIgcGJifHilPDQGpNwxMzQ1MDE0NDQ2",
      "expires_in": 3600,
      "token_type": "Bearer"
    }