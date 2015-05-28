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
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20150425104512) do

  create_table "messages", force: true do |t|
    t.integer  "recipient_id"
    t.integer  "sender_id"
    t.string   "cipher",             limit: 5000
    t.string   "sig_recipient"
    t.string   "iv"
    t.string   "key_recipient_enc", limit: 500
    t.boolean  "read",                          default: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", primary_key: "user_id", force: true do |t|
    t.string   "identity"
    t.string   "salt_masterkey"
    t.string   "pubkey_user",      limit: 500
    t.string   "privkey_user_enc", limit: 2300
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "users", ["identity"], name: "index_users_on_identity", unique: true

end
