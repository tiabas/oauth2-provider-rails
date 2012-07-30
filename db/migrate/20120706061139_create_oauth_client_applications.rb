class CreateOauthClientApplications < ActiveRecord::Migration
  def change
    create_table :oauth_client_applications do |t|
    	t.string :name
    	t.string :website
    	t.string :description
    	t.string :client_type
    	t.string :client_id
    	t.string :client_secret
      t.string :email_address
      t.string :redirect_uri
    	t.timestamps
    end
  end
end
