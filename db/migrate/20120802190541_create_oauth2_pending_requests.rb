class CreateOauth2PendingRequests < ActiveRecord::Migration
  def change
    create_table :oauth2_pending_requests do |t|
      t.string  :user_id
      t.string  :client_id
      t.string  :client_secret
      t.string  :redirect_uri
      t.string  :response_type
      t.string  :state
      t.string  :scope
      t.boolean :approved, :default => false
      t.timestamps
    end
  end
end
