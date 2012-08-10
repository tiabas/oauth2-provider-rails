class OauthTokenScope < ActiveRecord::Base

  attr_accessible nil

  belongs_to :oauth_token
end
