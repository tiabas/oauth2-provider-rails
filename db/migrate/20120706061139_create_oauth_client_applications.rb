class CreateOauthClientApplications < ActiveRecord::Migration
  def change
    create_table :oauth_clients do |t|
    	t.string :name
    	t.string :website
    	t.string :description
    	t.string :redirect_uri
    	t.string :client_type
    	t.string :client_id
    	t.string :client_secret
    	# t.string :access_token
    	# t.string :refresh_token
     	# t.string :code
     	# t.datetmime :code_created_at
    	t.timestamps
    end
  end
end
