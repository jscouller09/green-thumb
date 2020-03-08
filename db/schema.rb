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

ActiveRecord::Schema.define(version: 2020_03_08_184829) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.bigint "byte_size", null: false
    t.string "checksum", null: false
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "climate_zones", force: :cascade do |t|
    t.string "zone"
    t.integer "growing_season_days"
    t.date "start_of_growing_season"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "hemisphere"
  end

  create_table "conversations", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "gardens", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "weather_station_id"
    t.string "name"
    t.string "address"
    t.integer "length_mm"
    t.integer "width_mm"
    t.integer "x"
    t.integer "y"
    t.bigint "climate_zone_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.float "lat"
    t.float "lon"
    t.index ["climate_zone_id"], name: "index_gardens_on_climate_zone_id"
    t.index ["user_id"], name: "index_gardens_on_user_id"
    t.index ["weather_station_id"], name: "index_gardens_on_weather_station_id"
  end

  create_table "measurements", force: :cascade do |t|
    t.datetime "timestamp"
    t.datetime "sunrise"
    t.datetime "sunset"
    t.string "timezone_UTC_offset"
    t.float "temp_c"
    t.integer "humidity_perc"
    t.integer "pressure_hPa"
    t.float "wind_speed_mps"
    t.integer "wind_direction_deg"
    t.integer "cloudiness_perc"
    t.float "rain_1h_mm"
    t.float "rain_3h_mm"
    t.float "snow_1h_mm"
    t.float "snow_3h_mm"
    t.integer "code"
    t.string "main"
    t.string "description"
    t.string "icon"
    t.bigint "weather_station_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.float "temp_feels_like_c"
    t.string "wind_direction"
    t.index ["weather_station_id"], name: "index_measurements_on_weather_station_id"
  end

  create_table "messages", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "conversation_id"
    t.string "content"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["conversation_id"], name: "index_messages_on_conversation_id"
    t.index ["user_id"], name: "index_messages_on_user_id"
  end

  create_table "plant_types", force: :cascade do |t|
    t.string "name"
    t.string "scientific_name"
    t.integer "spacing_mm"
    t.integer "height_mm"
    t.date "earliest_plant_day"
    t.string "sunshine"
    t.float "kc_ini", default: 1.0
    t.float "kc_mid", default: 1.0
    t.float "kc_end", default: 1.0
    t.integer "l_ini_days"
    t.integer "l_dev_days"
    t.integer "l_mid_days"
    t.integer "l_end_days"
    t.string "photo_url"
    t.string "icon"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "plants", force: :cascade do |t|
    t.bigint "plot_id"
    t.bigint "plant_type_id"
    t.integer "x"
    t.integer "y"
    t.integer "radius_mm"
    t.date "plant_date"
    t.float "water_deficit_mm"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["plant_type_id"], name: "index_plants_on_plant_type_id"
    t.index ["plot_id"], name: "index_plants_on_plot_id"
  end

  create_table "plots", force: :cascade do |t|
    t.bigint "garden_id"
    t.string "name"
    t.string "shape"
    t.integer "length_mm"
    t.integer "width_mm"
    t.integer "x"
    t.integer "y"
    t.string "shady_spots"
    t.integer "rooting_depth_mm"
    t.string "soil_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.float "length_m", null: false
    t.float "width_m", null: false
    t.integer "grid_cell_size_mm"
    t.index ["garden_id"], name: "index_plots_on_garden_id"
  end

  create_table "tasks", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "plant_id"
    t.string "description"
    t.date "due_date"
    t.boolean "completed", default: false, null: false
    t.string "priority"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["plant_id"], name: "index_tasks_on_plant_id"
    t.index ["user_id"], name: "index_tasks_on_user_id"
  end

  create_table "user_conversations", id: false, force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "conversation_id", null: false
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "admin", default: false, null: false
    t.string "first_name"
    t.string "last_name"
    t.boolean "mentor", default: false, null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "waterings", force: :cascade do |t|
    t.bigint "plant_id"
    t.boolean "done", default: false, null: false
    t.float "ammount_L", default: 0.0, null: false
    t.float "ammount_mm", default: 0.0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["plant_id"], name: "index_waterings_on_plant_id"
  end

  create_table "weather_stations", force: :cascade do |t|
    t.string "name"
    t.string "country"
    t.float "lat"
    t.float "lon"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.float "elevation_m"
    t.float "tot_rain_24hr_mm"
    t.float "tot_pet_24_hr_mm"
    t.float "min_temp_24_hr_c"
    t.float "max_temp_24_hr_c"
    t.float "avg_humidity_24_hr_perc"
    t.float "avg_wind_speed_24_hr_mps"
    t.float "avg_pressure_24_hr_hPa"
    t.float "avg_temp_24_hr_c"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "messages", "conversations"
  add_foreign_key "messages", "users"
end
