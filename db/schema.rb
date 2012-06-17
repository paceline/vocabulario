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

ActiveRecord::Schema.define(:version => 20110731160135) do

  create_table "client_applications", :force => true do |t|
    t.string   "name"
    t.string   "url"
    t.string   "support_url"
    t.string   "callback_url"
    t.string   "key",          :limit => 40
    t.string   "secret",       :limit => 40
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "client_applications", ["key"], :name => "index_client_applications_on_key", :unique => true

  create_table "comments", :force => true do |t|
    t.integer  "user_id"
    t.integer  "commentable_id"
    t.string   "commentable_type"
    t.string   "text"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "conjugation_times", :force => true do |t|
    t.integer  "language_id"
    t.string   "name",        :limit => 25
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "permalink"
  end

  create_table "lists", :force => true do |t|
    t.integer  "user_id"
    t.integer  "language_from_id"
    t.integer  "language_to_id"
    t.string   "type",             :limit => 25
    t.string   "name"
    t.string   "permalink"
    t.boolean  "public",                         :default => true
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "time_value"
    t.string   "time_unit",        :limit => 10
    t.boolean  "all_or_any"
  end

  create_table "oauth_nonces", :force => true do |t|
    t.string   "nonce"
    t.integer  "timestamp"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "oauth_nonces", ["nonce", "timestamp"], :name => "index_oauth_nonces_on_nonce_and_timestamp", :unique => true

  create_table "oauth_tokens", :force => true do |t|
    t.integer  "user_id"
    t.string   "type",                  :limit => 20
    t.integer  "client_application_id"
    t.string   "token",                 :limit => 40
    t.string   "secret",                :limit => 40
    t.string   "callback_url"
    t.string   "verifier",              :limit => 20
    t.string   "scope"
    t.datetime "authorized_at"
    t.datetime "invalidated_at"
    t.datetime "valid_to"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "oauth_tokens", ["token"], :name => "index_oauth_tokens_on_token", :unique => true

  create_table "patterns", :force => true do |t|
    t.integer "conjugation_time_id"
    t.string  "name"
    t.integer "person"
  end

  create_table "patterns_rules", :force => true do |t|
    t.integer "pattern_id"
    t.integer "rule_id"
    t.integer "position"
  end

  add_index "patterns_rules", ["pattern_id"], :name => "index_patterns_rules_on_pattern_id"

  create_table "patterns_verbs", :id => false, :force => true do |t|
    t.integer "pattern_id"
    t.integer "verb_id"
  end

  add_index "patterns_verbs", ["pattern_id"], :name => "index_patterns_verbs_on_pattern_id"
  add_index "patterns_verbs", ["verb_id"], :name => "index_patterns_verbs_on_verb_id"

  create_table "rules", :force => true do |t|
    t.string "name"
    t.string "find"
    t.string "replace"
  end

  create_table "scores", :force => true do |t|
    t.integer  "user_id"
    t.integer  "language_from_id"
    t.integer  "points",           :default => 0
    t.integer  "questions"
    t.string   "test_type"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "language_to_id"
  end

  create_table "taggings", :force => true do |t|
    t.integer  "tag_id"
    t.integer  "taggable_id"
    t.string   "taggable_type"
    t.datetime "created_at"
  end

  add_index "taggings", ["tag_id"], :name => "index_taggings_on_tag_id"
  add_index "taggings", ["taggable_id", "taggable_type"], :name => "index_taggings_on_taggable_id_and_taggable_type"

  create_table "tags", :force => true do |t|
    t.string "name"
    t.string "permalink"
  end

  create_table "translations", :id => false, :force => true do |t|
    t.integer "vocabulary1_id", :null => false
    t.integer "vocabulary2_id", :null => false
  end

  add_index "translations", ["vocabulary1_id"], :name => "index_translations_on_vocabulary1_id"
  add_index "translations", ["vocabulary2_id"], :name => "index_translations_on_vocabulary2_id"

  create_table "users", :force => true do |t|
    t.string   "name"
    t.string   "permalink"
    t.integer  "default_from"
    t.integer  "default_to"
    t.string   "email",                                 :default => "",    :null => false
    t.string   "encrypted_password",     :limit => 128, :default => "",    :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                         :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.boolean  "admin",                                 :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true

  create_table "vocabularies", :force => true do |t|
    t.integer  "user_id"
    t.integer  "language_id"
    t.string   "type"
    t.string   "word"
    t.string   "gender",      :limit => 10, :default => "N/A"
    t.string   "permalink"
    t.string   "locale",      :limit => 5
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "vocabularies", ["permalink"], :name => "index_vocabularies_on_permalink"

  create_table "vocabulary_lists", :force => true do |t|
    t.integer "list_id"
    t.integer "vocabulary_id"
    t.integer "position"
  end

  add_index "vocabulary_lists", ["list_id"], :name => "index_vocabulary_lists_on_list_id"
  add_index "vocabulary_lists", ["vocabulary_id"], :name => "index_vocabulary_lists_on_vocabulary_id"

  create_table "wiki_page_versions", :force => true do |t|
    t.integer  "page_id",    :null => false
    t.integer  "updator_id"
    t.integer  "number"
    t.string   "comment"
    t.string   "path"
    t.string   "title"
    t.text     "content"
    t.datetime "updated_at"
  end

  add_index "wiki_page_versions", ["page_id"], :name => "index_wiki_page_versions_on_page_id"
  add_index "wiki_page_versions", ["updator_id"], :name => "index_wiki_page_versions_on_updator_id"

  create_table "wiki_pages", :force => true do |t|
    t.integer  "creator_id"
    t.integer  "updator_id"
    t.integer  "language_id"
    t.string   "path"
    t.string   "title"
    t.text     "content"
    t.boolean  "public",      :default => true
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "wiki_pages", ["creator_id"], :name => "index_wiki_pages_on_creator_id"
  add_index "wiki_pages", ["path"], :name => "index_wiki_pages_on_path", :unique => true

end
