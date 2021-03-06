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

  create_table "access_token_scopes", :force => true do |t|
    t.boolean  "profile"
    t.boolean  "files"
    t.boolean  "messages"
    t.boolean  "pages"
    t.boolean  "groups"
    t.boolean  "networks"
    t.boolean  "invitations"
    t.boolean  "presences"
    t.boolean  "communities"
    t.boolean  "read_follower_lists"
    t.datetime "created_at",          :null => false
    t.datetime "updated_at",          :null => false
  end

  create_table "access_tokens", :force => true do |t|
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

  create_table "authorization_codes", :force => true do |t|
    t.integer  "client_application_id"
    t.integer  "user_id"
    t.string   "code"
    t.string   "redirect_uri"
    t.datetime "deactivated_at"
    t.datetime "created_at",            :null => false
    t.datetime "updated_at",            :null => false
  end

  create_table "client_applications", :force => true do |t|
    t.string   "name"
    t.string   "website"
    t.string   "description"
    t.string   "email_address"
    t.string   "redirect_uri"
    t.string   "client_type"
    t.string   "client_id"
    t.string   "client_secret"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

  create_table "pending_authorization_requests", :force => true do |t|
    t.integer  "user_id",                           :null => false
    t.string   "client_id",                         :null => false
    t.string   "redirect_uri"
    t.string   "response_type",                     :null => false
    t.string   "state"
    t.string   "scope"
    t.boolean  "approved",       :default => false
    t.string   "signature",                         :null => false
    t.datetime "deactivated_at"
    t.datetime "created_at",                        :null => false
    t.datetime "updated_at",                        :null => false
  end

  create_table "users", :force => true do |t|
    t.string   "first_name"
    t.string   "last_name"
    t.string   "email"
    t.string   "password_digest"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
  end

end
