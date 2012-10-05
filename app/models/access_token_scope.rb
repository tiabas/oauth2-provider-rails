class AccessTokenScope < ActiveRecord::Base

  CLIENT_SCOPES = [ :profile, :files, :pages, :topics, :communities, :activities, :messages,
                    :notifications, :invitations, :groups, :relationships]

  attr_accessible CLIENT_SCOPES

  belongs_to :access_token

end
