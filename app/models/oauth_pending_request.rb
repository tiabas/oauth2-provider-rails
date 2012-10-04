class OauthPendingRequest < ActiveRecord::Base

  attr_accessible :client_id, :redirect_uri, :response_type, :scope, :state

  validate :requested_scope_must_include_approved_scope, :on => :update

  validate_presence_of :client_id, :user_id, :response_type

  before_save :generate_signature

  private

  def generate_signature
    key = self.id.to_s
    raw = [self.user_id, Time.now.to_i, self.client_id].join(" ")
    self.signature = Digest::HMAC.hexdigest(key, raw, Digest::SHA1)
  end

  def requested_scope_must_include_approved_scope
    return unless self.scope
    previous_scope = scope_was.split(' ')
    approved_scope = scope.split(' ')
    scope_errors = []
    approved_scope.each do |value|
      next if previous_scope.include? value
      scope_errors << "scope, #{value}, is invalid"
    end
    errors.add(scope_errors.join(", ")) unless scope_errors.empty?
  end
end
