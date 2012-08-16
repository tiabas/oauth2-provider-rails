class OauthAccessToken < ActiveRecord::Base
  extend OAuth2::Helper

  attr_accessible :user_id, :client_id, :scope, :expires_in, :token_type, :refresh_token, :token, :scope 

  validates_presence_of :token, :token_type, :expires_in, :refresh_token #, :access_type, :scope
  
  validates_uniqueness_of :refresh_token, :scope => [:client_id]

  validate :validate_scope


  belongs_to :user  
  
  belongs_to :oauth_client_application

  has_one :oauth_token_scope


  before_create :build_token_scope

  def self.generate_from_refresh_token(client, ref_token, opts={})
    token = where(
                :client_id => client.id,
                :refresh_token => ref_token
              ).first
    token.refresh! if token
    token
  end

  def self.generate_token(client, user=nil, opts={})
    scope = opts[:scope] || 'default'
    expires_in = opts[:expires_in] || 3600
    token_type = opts[:token_type] || 'Bearer'
    refreshable = opts[:refreshable] || true
    refresh_token = refreshable ? generate_urlsafe_key : nil
    token = create!(
              :client_id => client.id,
              :user_id => user.try(:id),
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
    update_attribute :access_token, generate_urlsafe_key
  end

  def validate_scope
    scope_errors = []
    scope.split(",").each do |scope|
      next if OauthTokenScope.SCOPE_VAlUES.include? scope
      scope_errors << "invalid scope #{scope}"
    end
    if scope_errors.any?
      @errors[:scope] = scope_errors.join(", ")
      return false
    end
    true
  end

  def to_oauth_response
    {
      :access_token => token,
      :token_type => token_type,
      :expires_in => expires_in,
      :refresh_token => refresh_token
    }
  end

  private

    def build_token_scope

    end
end
