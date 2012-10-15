class CreatePendingAuthorizationRequests < ActiveRecord::Migration
  def change
    create_table :pending_authorization_requests do |t|
      t.integer  :user_id, :null => false
      t.string   :client_id, :null => false
      t.string   :redirect_uri
      t.string   :response_type, :null => false
      t.string   :state
      t.string   :scope
      t.boolean  :approved, :default => false
      t.string   :signature, :null => false
      t.datetime :deactivated_at
      t.timestamps
    end
  end
end
