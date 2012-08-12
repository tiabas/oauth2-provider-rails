class CreateOauthAuthorizationCodes < ActiveRecord::Migration
  def change
    # TODO
    # consider tying authorization code to user too
    create_table :oauth_authorization_codes do |t|
      t.integer :client_application_id
      # t.integer :user_id
      t.string  :code
      t.string  :redirect_uri
      t.timestamps
    end
  end
end
