class Oauth2PendingRequest < ActiveRecord::Base
  attr_accessible :client_id, :client_secret, :redirect_uri, :response_type, :scope, :state

  validate :requested_scope_must_include_approved_scope, :on => :update

  def scope_values
    return [] unless self.scope
    scopes = self.scope.split(' ')
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
