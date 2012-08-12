class User < ActiveRecord::Base
  attr_accessible :email, :first_name, :last_name, :password, :password_confirmation

  has_many :oauth_access_token

  has_secure_password

  validates_presence_of :password, :on => :create
  
  def self.authenticate(email, password)
    find_by_email(email).try(:authenticate, password)
  end
end
