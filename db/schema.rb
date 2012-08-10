# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20120808054440) do

  create_table "oauth_access_tokens", :force => true do |t|
    t.integer  "user_id"
    t.integer  "client_id"
    t.string   "token"
    t.string   "token_type"
    t.string   "refresh_token"
    t.integer  "expires_in"
    t.datetime "deactivated_at"
    t.string   "access_type"
    t.string   "scope"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
  end

  create_table "oauth_authorization_codes", :force => true do |t|
    t.integer  "client_id"
    t.string   "code"
    t.string   "redirect_uri"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
  end

  create_table "oauth_client_applications", :force => true do |t|
    t.string   "name"
    t.string   "website"
    t.string   "description"
    t.string   "client_type"
    t.string   "client_id"
    t.string   "client_secret"
    t.string   "email_address"
    t.string   "redirect_uri"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

  create_table "oauth_pending_requests", :force => true do |t|
    t.string   "user_id"
    t.string   "client_id"
    t.string   "client_secret"
    t.string   "redirect_uri"
    t.string   "response_type"
    t.string   "state"
    t.string   "scope"
    t.boolean  "approved",      :default => false
    t.datetime "created_at",                       :null => false
    t.datetime "updated_at",                       :null => false
  end

  create_table "oauth_token_scopes", :force => true do |t|
    t.boolean  "user_profile"
    t.boolean  "user_files"
    t.boolean  "user_messages"
    t.boolean  "user_pages"
    t.boolean  "user_groups"
    t.boolean  "user_networks"
    t.boolean  "user_invitations"
    t.boolean  "user_presences"
    t.boolean  "read_follower_lists"
    t.datetime "created_at",          :null => false
    t.datetime "updated_at",          :null => false
  end

  create_table "users", :force => true do |t|
    t.string   "first_name"
    t.string   "last_name"
    t.string   "email"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

end
