# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20090913110133) do

  create_table "conjugation_times", :force => true do |t|
    t.integer  "language_id"
    t.string   "name",        :limit => 25
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "conjugations", :force => true do |t|
    t.integer  "conjugation_time_id"
    t.string   "name",                   :limit => 25
    t.boolean  "regular",                              :default => true, :null => false
    t.string   "first_person_singular",  :limit => 50
    t.string   "second_person_singular", :limit => 50
    t.string   "third_person_singular",  :limit => 50
    t.string   "first_person_plural",    :limit => 50
    t.string   "second_person_plural",   :limit => 50
    t.string   "third_person_plural",    :limit => 50
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "conjugations_verbs", :id => false, :force => true do |t|
    t.integer "conjugation_id"
    t.integer "verb_id"
  end

  create_table "people", :force => true do |t|
    t.integer  "language_id"
    t.string   "first_person_singular",  :limit => 50
    t.string   "second_person_singular", :limit => 50
    t.string   "third_person_singular",  :limit => 50
    t.string   "first_person_plural",    :limit => 50
    t.string   "second_person_plural",   :limit => 50
    t.string   "third_person_plural",    :limit => 50
    t.string   "pronoun",                :limit => 50
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "scores", :force => true do |t|
    t.integer  "user_id"
    t.integer  "language_from_id"
    t.integer  "points",                         :default => 0
    t.integer  "questions"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "language_to_id"
    t.string   "test_type",        :limit => 50
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

  create_table "transformations", :force => true do |t|
    t.string   "type",                :limit => 50
    t.integer  "vocabulary_id"
    t.integer  "position"
    t.integer  "pattern_start"
    t.integer  "pattern_end"
    t.integer  "insert_before"
    t.boolean  "include_white_space",               :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "translations", :id => false, :force => true do |t|
    t.integer "vocabulary1_id", :null => false
    t.integer "vocabulary2_id", :null => false
  end

  add_index "translations", ["vocabulary1_id", "vocabulary2_id"], :name => "vocabulary1_id_vocabulary2_id_index", :unique => true

  create_table "users", :force => true do |t|
    t.string   "login",              :limit => 40
    t.string   "name",               :limit => 100
    t.string   "email",              :limit => 100
    t.string   "salt",               :limit => 40
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "remember_token",     :limit => 40
    t.boolean  "admin",                             :default => false
    t.string   "encrypted_password", :limit => 128
    t.string   "confirmation_token", :limit => 128
    t.boolean  "email_confirmed",                   :default => false, :null => false
  end

  add_index "users", ["email"], :name => "index_users_on_email"
  add_index "users", ["id", "confirmation_token"], :name => "index_users_on_id_and_confirmation_token"
  add_index "users", ["login"], :name => "index_users_on_login", :unique => true
  add_index "users", ["remember_token"], :name => "index_users_on_remember_token"

  create_table "vocabularies", :force => true do |t|
    t.integer  "user_id"
    t.integer  "language_id"
    t.string   "word"
    t.string   "gender",      :limit => 10, :default => "N/A"
    t.string   "permalink"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "type",        :limit => 25
    t.string   "comment",                   :default => "-"
  end

end
