class CreateOauthAuthorizationCodes < ActiveRecord::Migration
  def change
    create_table :oauth_authorization_codes do |t|
      t.integer :client_id
      t.string  :code
      t.string  :redirect_uri
      t.timestamps
    end
  end
end
