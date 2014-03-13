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

ActiveRecord::Schema.define(version: 20140310205004) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "activities", force: true do |t|
    t.integer  "user_id"
    t.integer  "prediction_id"
    t.text     "prediction_body"
    t.string   "activity_type"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "seen",            default: false
    t.text     "title"
  end

  add_index "activities", ["user_id"], name: "index_activities_on_user_id", using: :btree

  create_table "android_device_tokens", force: true do |t|
    t.integer  "user_id"
    t.string   "token"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "android_device_tokens", ["user_id", "token"], name: "index_android_device_tokens_on_user_id_and_token", unique: true, using: :btree

  create_table "apple_device_tokens", force: true do |t|
    t.integer  "user_id"
    t.string   "token"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "sandbox",    default: false
  end

  add_index "apple_device_tokens", ["user_id", "token"], name: "index_apple_device_tokens_on_user_id_and_token", unique: true, using: :btree

  create_table "badges", force: true do |t|
    t.integer  "user_id"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "seen",       default: false
  end

  add_index "badges", ["user_id"], name: "index_badges_on_user_id", using: :btree

  create_table "challenges", force: true do |t|
    t.integer  "user_id"
    t.integer  "prediction_id"
    t.boolean  "agree"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "seen",          default: false
    t.boolean  "is_own",        default: false
    t.boolean  "is_right",      default: false
    t.boolean  "is_finished",   default: false
    t.boolean  "bs",            default: false
  end

  add_index "challenges", ["prediction_id"], name: "index_challenges_on_prediction_id", using: :btree
  add_index "challenges", ["user_id", "prediction_id"], name: "index_challenges_on_user_id_and_prediction_id", unique: true, using: :btree
  add_index "challenges", ["user_id"], name: "index_challenges_on_user_id", using: :btree

  create_table "comments", force: true do |t|
    t.integer  "user_id"
    t.integer  "prediction_id"
    t.string   "text",          limit: 300
    t.boolean  "seen",                      default: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "comments", ["prediction_id"], name: "index_comments_on_prediction_id", using: :btree
  add_index "comments", ["user_id"], name: "index_comments_on_user_id", using: :btree

  create_table "groups", force: true do |t|
    t.string   "name",                default: "", null: false
    t.string   "description"
    t.integer  "owner_id"
    t.string   "share_url"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "avatar_file_name"
    t.string   "avatar_content_type"
    t.integer  "avatar_file_size"
    t.datetime "avatar_updated_at"
  end

  create_table "invitations", force: true do |t|
    t.integer "user_id",           null: false
    t.integer "group_id"
    t.string  "code"
    t.integer "recipient_user_id"
    t.string  "recipient_email"
    t.boolean "active"
  end

  create_table "memberships", force: true do |t|
    t.integer "user_id",                     null: false
    t.integer "group_id",                    null: false
    t.string  "role",     default: "MEMBER", null: false
  end

  add_index "memberships", ["user_id", "group_id"], name: "index_memberships_on_user_id_and_group_id", unique: true, using: :btree

  create_table "predictions", force: true do |t|
    t.integer  "user_id"
    t.text     "body"
    t.datetime "expires_at"
    t.boolean  "outcome"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "closed_at"
    t.boolean  "is_closed",        default: false
    t.datetime "push_notified_at"
    t.string   "short_url"
    t.datetime "resolutionDate"
    t.datetime "resolution_date",                  null: false
    t.datetime "activity_sent_at"
    t.string   "tags",             default: [],                 array: true
    t.integer  "group_id"
  end

  add_index "predictions", ["tags"], name: "index_predictions_on_tags", using: :gin
  add_index "predictions", ["user_id"], name: "index_predictions_on_user_id", using: :btree

  create_table "topics", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "hidden",     default: false
    t.integer  "sort_order", default: 99
  end

  add_index "topics", ["name"], name: "index_topics_on_name", unique: true, using: :btree

  create_table "users", force: true do |t|
    t.string   "email",                  default: "",    null: false
    t.string   "encrypted_password",     default: "",    null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "admin",                  default: false
    t.string   "username"
    t.boolean  "notifications",          default: true
    t.string   "authentication_token"
    t.string   "avatar_file_name"
    t.string   "avatar_content_type"
    t.integer  "avatar_file_size"
    t.datetime "avatar_updated_at"
    t.integer  "points",                 default: 0
    t.integer  "streak",                 default: 0
    t.boolean  "verified_account",       default: false
  end

  add_index "users", ["authentication_token"], name: "index_users_on_authentication_token", using: :btree
  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
  add_index "users", ["username"], name: "index_users_on_username", unique: true, using: :btree

end
