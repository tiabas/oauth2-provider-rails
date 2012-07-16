class CreateOauthAccessTokens < ActiveRecord::Migration
  def change
    create_table :oauth_access_tokens do |t|
    	t.string  :token
    	t.string  :token_type
    	t.string  :refresh_token
    	t.integer :expires_in
    	t.integer :client_id
      t.timestamps
    end
  end
end
