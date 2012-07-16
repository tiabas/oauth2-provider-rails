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

ActiveRecord::Schema.define(:version => 20120716023643) do

  create_table "oauth_access_tokens", :force => true do |t|
    t.string   "token"
    t.string   "token_type"
    t.string   "refresh_token"
    t.integer  "expires_in"
    t.integer  "client_id"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

  create_table "oauth_authorization_codes", :force => true do |t|
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "oauth_clients", :force => true do |t|
    t.string   "name"
    t.string   "website"
    t.string   "description"
    t.string   "client_type"
    t.string   "client_id"
    t.string   "client_secret"
    t.string   "salt"
    t.string   "redirect_uri"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

end
