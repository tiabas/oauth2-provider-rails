class ClientApplication < ActiveRecord::Base
  include OAuth2::Helper
  
  CLIENT_TYPES = { 
                  "Native" => '1',
                  "Web" => '2',
                  "User agent" => '3',
                  "Service" => '4'
                 }

  attr_accessible :name, :website, :description, :email, :redirect_uri, :terms_of_service
  attr_protected  :client_id, :client_secret, :client_type
  
  validates :name, :website, :redirect_uri, :description, :client_id,
            :client_secret, :client_type, :terms_of_service,
            :presence => true

  validates :client_id,
            :uniqueness =>  { :case_sensitive => false }

  validates :client_secret,
            :uniqueness => true

  validates :client_type,
            :inclusion => { :in => CLIENT_TYPES.values }

  validates :terms_of_service,
            :acceptance => true,
            :on => :create

  has_many  :access_token
  has_many  :authorization_code

  before_validation :generate_credentials, :on => :create

  def self.find_client_with_id(c_id)
    self.find_by_client_id(c_id)
  end

  def self.authenticate(client_id, client_secret)
    find_by_client_id(client_id).try(:authenticate, client_secret)
  end

  def reset_client_secret!
    self.update_attribute(:client_secret, generate_client_secret)
  end

  def authenticate(secret)
    self.client_secret == secret
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
end
