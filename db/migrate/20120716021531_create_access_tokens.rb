class CreateAccessTokens < ActiveRecord::Migration
  #TODO add unique constraint on user, client, token and token_type
  def change
    create_table :access_tokens do |t|
      t.integer  :user_id
      t.integer  :client_id
    	t.string   :token
    	t.string   :token_type
    	t.string   :refresh_token
    	t.integer  :expires_in
      t.datetime :deactivated_at
      t.string   :access_type
      t.string   :scope
      t.timestamps
    end
  end
end
