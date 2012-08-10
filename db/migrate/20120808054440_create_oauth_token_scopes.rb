class CreateOauthTokenScopes < ActiveRecord::Migration
  def change
    create_table :oauth_token_scopes do |t|
      t.boolean :user_profile
      t.boolean :user_files
      t.boolean :user_messages
      t.boolean :user_pages
      t.boolean :user_groups
      t.boolean :user_networks
      t.boolean :user_invitations
      t.boolean :user_presences
      t.boolean :read_follower_lists
      t.timestamps
    end
  end
end
