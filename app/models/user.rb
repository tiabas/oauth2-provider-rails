class User < ActiveRecord::Base
  attr_accessible :email, :first_name, :last_name

  has_many :oauth_access_token
end
