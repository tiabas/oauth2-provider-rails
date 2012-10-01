class CreateClientApplications < ActiveRecord::Migration
  def change
    create_table :client_applications do |t|
    	t.string :name
    	t.string :website
    	t.string :description
      t.string :email_address
      t.string :redirect_uri
    	t.string :client_type
    	t.string :client_id
    	t.string :client_secret
    	t.timestamps
    end
  end
end
