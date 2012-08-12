class OauthAuthorizationCode < ActiveRecord::Base
  extend OAuth2::Helper

  attr_accessible :client_application_id, :user_id, :code, :redirect_uri

   belongs_to :oauth_client_application, :foreign_key => "client_application_id"

  validates_presence_of :client_application_id, :code, :redirect_uri

  def self.generate_authorization_code(client, redirect_uri)
    kode = create!(
              :code => generate_urlsafe_key,
              :client_application_id => client.id,
              :redirect_uri => redirect_uri
            )
    kode.code
  end

  def self.verify_authorization_code(client, code, redirect_uri)
    where(:client_application_id => client.id, :code => code, :redirect_uri => redirect_uri).first
  end

  def expired?
    false
  end

  def deactivated?
    false
  end

  def deactivate!
    # self.update_attribute :deactivated_at, Time.now
  end
end
