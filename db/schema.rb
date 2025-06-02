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

ActiveRecord::Schema[7.1].define(version: 2025_06_02_221612) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "animes", force: :cascade do |t|
    t.string "title"
    t.text "synopsis"
    t.integer "mal_id"
    t.float "score"
    t.integer "episodes"
    t.string "status"
    t.date "aired_from"
    t.date "aired_to"
    t.string "image_url"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "genres", default: [], array: true
    t.integer "anilist_id"
    t.string "title_romaji"
    t.string "title_english"
    t.string "title_native"
    t.integer "episode_duration"
    t.float "mean_score"
    t.integer "popularity"
    t.integer "favourites"
    t.integer "trending"
    t.string "season"
    t.integer "season_year"
    t.string "format"
    t.string "source"
    t.text "studios", default: [], array: true
    t.string "country_of_origin"
    t.boolean "is_licensed"
    t.string "hashtag"
    t.string "trailer_url"
    t.string "trailer_thumbnail"
    t.string "banner_image"
    t.string "cover_image_color"
    t.string "site_url"
    t.jsonb "tags", default: {}
    t.jsonb "external_links", default: {}
    t.jsonb "streaming_episodes", default: {}
    t.jsonb "rankings", default: {}
    t.jsonb "stats", default: {}
    t.index ["format"], name: "index_animes_on_format"
    t.index ["genres"], name: "index_animes_on_genres", using: :gin
    t.index ["popularity"], name: "index_animes_on_popularity"
    t.index ["season_year"], name: "index_animes_on_season_year"
    t.index ["trending"], name: "index_animes_on_trending"
  end

  create_table "goals", force: :cascade do |t|
    t.string "name"
    t.string "sport"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id"
  end

  create_table "rankings", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "anime_id", null: false
    t.decimal "score"
    t.text "comment"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["anime_id"], name: "index_rankings_on_anime_id"
    t.index ["user_id"], name: "index_rankings_on_user_id"
  end

  create_table "trainers", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "user_trainers", force: :cascade do |t|
    t.integer "user_id"
    t.integer "trainer_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "username"
    t.string "email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "password_digest"
    t.boolean "admin", default: false
  end

  add_foreign_key "rankings", "animes"
  add_foreign_key "rankings", "users"
end
