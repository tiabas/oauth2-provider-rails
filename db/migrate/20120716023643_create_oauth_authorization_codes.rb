class CreateOauthAuthorizationCodes < ActiveRecord::Migration
  #TODO: add unique constraint on user, client and code
  def change
    create_table :oauth_authorization_codes do |t|
      t.integer :client_application_id
      t.integer :user_id
      t.string  :code
      t.string  :redirect_uri
      t.timestamps
    end
  end
end
