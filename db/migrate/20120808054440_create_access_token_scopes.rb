class CreateAccessTokenScopes < ActiveRecord::Migration
  def change
    create_table :access_token_scopes do |t|
      # t.integer :access_token_id
      t.boolean :profile
      t.boolean :files
      t.boolean :messages
      t.boolean :pages
      t.boolean :groups
      t.boolean :networks
      t.boolean :invitations
      t.boolean :presences
      t.boolean :communities
      t.boolean :read_follower_lists
      t.timestamps
    end
  end
end
