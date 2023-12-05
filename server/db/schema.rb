# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.1].define(version: 2023_11_23_195918) do
  create_table "games", force: :cascade do |t|
    t.string "name", null: false
    t.string "icon"
    t.integer "min_age"
    t.datetime "deleted_at"
    t.string "command"
    t.text "environment"
    t.integer "default_version_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["default_version_id"], name: "index_games_on_default_version_id"
  end

  create_table "saves", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "version_id", null: false
    t.integer "station_id", null: false
    t.integer "size"
    t.json "bucket", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.index ["station_id"], name: "index_saves_on_station_id"
    t.index ["user_id"], name: "index_saves_on_user_id"
    t.index ["version_id"], name: "index_saves_on_version_id"
  end

  create_table "sessions", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "version_id", null: false
    t.datetime "started_at", null: false
    t.integer "duration", null: false
    t.integer "idle_time", null: false
    t.index ["user_id"], name: "index_sessions_on_user_id"
    t.index ["version_id"], name: "index_sessions_on_version_id"
  end

  create_table "stations", force: :cascade do |t|
    t.string "hostname", null: false
    t.datetime "last_seen", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
  end

  create_table "users", force: :cascade do |t|
    t.string "name", null: false
    t.string "icon"
    t.string "password", null: false
    t.datetime "last_login"
    t.integer "age"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "versions", force: :cascade do |t|
    t.integer "game_id", null: false
    t.string "number", null: false
    t.integer "size", null: false
    t.json "bucket", null: false
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["game_id"], name: "index_versions_on_game_id"
  end

end
