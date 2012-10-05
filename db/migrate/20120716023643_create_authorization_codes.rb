class CreateAuthorizationCodes < ActiveRecord::Migration
  #TODO: add unique constraint on user, client and code
  def change
    create_table :authorization_codes do |t|
      t.integer  :client_application_id
      t.integer  :user_id
      t.string   :code
      t.string   :redirect_uri
      t.datetime :deactivated_at
      t.timestamps
    end
  end
end
