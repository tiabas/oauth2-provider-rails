class AuthorizationCode < ActiveRecord::Base
  extend OAuth2::Helper

  EXPIRES_IN = 600

  attr_accessible :client_application_id, :user_id, :code, :redirect_uri

  belongs_to :client_application
  belongs_to :user

  validates_presence_of :client_application_id, :code, :redirect_uri, :user_id

  def self.generate_authorization_code(opts={})
    user = opts[:user]
    client = opts[:client]
    redirect_uri = opts[:redirect_uri]
    kode = create!(
              :code => generate_urlsafe_key,
              :user_id => user.id,
              :client_application_id => client.id,
              :redirect_uri => redirect_uri
            )
    kode.code
  end

  def self.verify(opts={})
    client = opts[:client]
    code = opts[:code]
    redirect_uri = opts[:redirect_uri]
    where(:client_application_id => client.id, :code => code, :redirect_uri => redirect_uri).first
  end

  def expired?
    (Time.now - created_at) > EXPIRES_IN
  end

  def active?
    !deactivated_at
  end

  def deactivated?
    !active?
  end

  def deactivate!
    self.deactivated_at = Time.now
    save
  end
end
