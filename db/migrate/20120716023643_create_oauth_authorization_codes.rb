class CreateOauthAuthorizationCodes < ActiveRecord::Migration
  def change
    create_table :oauth_authorization_codes do |t|

      t.timestamps
    end
  end
end
