class OauthAccessToken < ActiveRecord::Base
  extend OAuth2::Helper

  attr_accessible :user_id, :client_id, :scope, :expires_in, :token_type, :refresh_token, :token

  CLIENT_SCOPES = %w{ scope1 scope2 scope3 }

  validates_presence_of :token, :token_type, :expires_in, :refresh_token #, :access_type
  
  validates_uniqueness_of :refresh_token, :scope => [:client_id]


  belongs_to :user  
  
  belongs_to :oauth_client_application, :foreign_key => "client_id"


  def self.refresh(client, ref_token)
    token = find_by(
                :client_id => client.id,
                :refresh_token => ref_token
                )
    token.refresh! unless token.nil?
    token
  end

  def self.generate_user_token(client, user, opts={})
    scope = opts[:scope] || 'default'
    expires_in = opts[:expires_in] || 3600
    token_type = opts[:token_type] || 'Bearer'
    refreshable = opts[:refreshable] || true
    refresh_token = refreshable ? generate_urlsafe_key : nil
    token = create!(
              :client_id => client.id,
              :user_id => user.id,
              :token => generate_urlsafe_key,
              :token_type => token_type,
              :refresh_token => refresh_token,
              :scope => scope,
              :expires_in => expires_in
            )
    token
  end

  def expired?
    (updated_at + expires_in) <= Time.now
  end

  def deactivate!
    update_attribute :deactivated_at, Time.now
  end

  def inactive?
    !!deactivated_at
  end 

  def active?
    !inactive?
  end 

  def refresh!
    update_attribute :token, generate_urlsafe_key
  end

  # def validate_scope
  #   scope_errors = []
  #   scope.split(",").each do |scope|
  #     scope_errors << "invalid scope #{scope}"
  #   end
  #   @errors[:scope] = scope_errors.join(", ") if scope_errors.any?
  # end

  def to_hsh
    {
      :token => token,
      :token_type => token_type,
      :expires_in => expires_in,
      :refresh_token => refresh_token
    }
  end
end
