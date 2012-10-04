class OauthTokenScope < ActiveRecord::Base

  CLIENT_SCOPES = [ :profile, :files, :pages, :topics, :communities, :activities, :messages,
                    :notifications, :invitations, :groups, :relationships]

  attr_accessible CLIENT_SCOPES

  belongs_to :oauth_access_token

end
