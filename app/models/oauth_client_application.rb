class OauthClientApplication < ActiveRecord::Base
  include OAuth2::Helper
  
  CLIENT_TYPES = %w{ native web user-agent }

  attr_accessible :name, :website, :description, :client_type, :redirect_uri

  
  validates :name, :website, :redirect_uri, :description, :client_id,
            :client_secret, :client_type,
            :presence => true

  validates :client_id,
            :uniqueness =>  { :case_sensitive => false }

  validates :client_secret,
            :uniqueness => true

  validates :client_type,
            :inclusion => { :in => CLIENT_TYPES }

  # validates :terms_of_service,
  #           :acceptance => true,
  #           :on => :create_client_id

  has_many  :oauth_access_token
  has_many  :oauth_authorization_code

  before_validation :generate_credentials, :on => :create
  def self.find_client_with_id(c_id)
    self.find_by_client_id c_id
  end

  def reset_client_secret!
    self.update_attribute(:client_secret, generate_client_secret)
  end

private

  def generate_credentials
    self.client_id ||= generate_client_secret
    self.client_secret ||= generate_client_secret
  end

  def generate_client_id
    generate_urlsafe_key(24)
  end

  def generate_client_secret
    generate_urlsafe_key(32)
  end

  def verify_secret(secret)
    self.client_secret == secret
  end
end
