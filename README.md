# OAuth2 Server Side Demo 
This is a demo rails application that shows how to use the oauth2-ruby gem to create an oauth2 implementation on the server side.


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

    # Authorization Endpoint
    # This is the endpoint that would be used for the Implicit grant flow
    def authorize
      handle_oauth_exception do
        @oa_request = OAuth2::Server::Request.new params.symbolize_keys
        handler = OAuth2::Server::RequestHandler.new(@oa_request)
        handler.verify_client_id
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


When the user submits the rendenred form, the data is posted to the 'process_authorization' action of the oauth controller

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


## Resources
* [View oauth2-ruby source on Github][code]

[code]: https://github.com/tiabas/oauth2-ruby

