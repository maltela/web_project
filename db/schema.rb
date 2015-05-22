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
    t.integer "recipient_id"
    t.integer "sender_id"
    t.text    "cipher"
    t.text    "sig_recipient"
    t.text    "iv"
    t.text    "key_recipient_enc"
    t.text    "created_at"
    t.text    "updated_at"
    t.text    "timestamp"
    t.text    "receiver"
    t.text    "sig_service"
    t.text    "sig_message"
    t.text    "message_object"
  end

  create_table "users", primary_key: "user_id", force: true do |t|
    t.string   "identity"
    t.string   "salt_masterkey"
    t.string   "pubkey_user"
    t.string   "privkey_user_enc"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
