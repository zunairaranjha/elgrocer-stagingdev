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

ActiveRecord::Schema[6.1].define(version: 20220519131333) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "postgis"
  enable_extension "pg_stat_statements"

  create_table "a_location_without_shops", id: :serial, force: :cascade do |t|
    t.string "name"
    t.integer "shopper_id"
    t.string "email"
    t.decimal "latitude", precision: 11, scale: 8
    t.decimal "longitude", precision: 11, scale: 8
    t.boolean "is_notified"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "street_address"
    t.string "street_number"
    t.string "route"
    t.string "intersection"
    t.string "political"
    t.string "country"
    t.string "administrative_area_level_1"
    t.string "locality"
    t.string "ward"
    t.string "sublocality"
    t.string "neighborhood"
    t.string "premise"
    t.string "subpremise"
    t.integer "postal_code"
    t.string "natural_feature"
    t.string "airport"
    t.string "park"
    t.string "store_name"
  end

  create_table "active_admin_comments", id: :serial, force: :cascade do |t|
    t.string "namespace"
    t.text "body"
    t.string "resource_id", null: false
    t.string "resource_type", null: false
    t.integer "author_id"
    t.string "author_type"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["author_type", "author_id"], name: "index_active_admin_comments_on_author_type_and_author_id"
    t.index ["namespace"], name: "index_active_admin_comments_on_namespace"
    t.index ["resource_type", "resource_id"], name: "index_active_admin_comments_on_resource_type_and_resource_id"
  end

  create_table "address_tags", id: :serial, force: :cascade do |t|
    t.string "name"
    t.string "name_ar"
    t.integer "priority", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "admin_users", id: :serial, force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet "current_sign_in_ip"
    t.inet "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "role_id"
    t.string "current_time_zone"
    t.index ["email"], name: "index_admin_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_admin_users_on_reset_password_token", unique: true
  end

  create_table "analytics", id: :serial, force: :cascade do |t|
    t.integer "event_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "owner_id"
    t.string "owner_type"
    t.string "detail"
    t.string "date_time_offset"
    t.index ["owner_id", "owner_type"], name: "index_analytics_on_owner"
  end

  create_table "authorizations", id: :serial, force: :cascade do |t|
    t.string "provider"
    t.string "uid"
    t.string "token"
    t.integer "shopper_id"
    t.string "secret"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["shopper_id"], name: "index_authorizations_on_shopper_id"
  end

  create_table "available_payment_types", id: :serial, force: :cascade do |t|
    t.string "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "bank_transactions", id: false, force: :cascade do |t|
    t.integer "main_merchant_no"
    t.integer "suffix"
    t.string "terminal"
    t.string "commercial_name"
    t.string "txn_date"
    t.string "voucher_no"
    t.string "card_type"
    t.string "card_no"
    t.string "auth_id"
    t.string "txn_ccy"
    t.decimal "txn_amount"
    t.string "bill_ccy"
    t.decimal "bill_amount"
    t.decimal "comm_amount"
    t.decimal "vat_amount"
    t.decimal "net_amount"
    t.string "file_name"
  end

  create_table "banner_links", id: :serial, force: :cascade do |t|
    t.integer "banner_id"
    t.integer "category_id"
    t.integer "subcategory_id"
    t.integer "brand_id"
    t.integer "priority"
    t.string "photo_file_name"
    t.string "photo_content_type"
    t.integer "photo_file_size"
    t.datetime "photo_updated_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["banner_id"], name: "index_banner_links_on_banner_id"
    t.index ["brand_id"], name: "index_banner_links_on_brand_id"
    t.index ["category_id"], name: "index_banner_links_on_category_id"
    t.index ["subcategory_id"], name: "index_banner_links_on_subcategory_id"
  end

  create_table "banners", id: :serial, force: :cascade do |t|
    t.string "title"
    t.string "title_ar"
    t.string "subtitle"
    t.string "subtitle_ar"
    t.string "desc"
    t.string "desc_ar"
    t.string "btn_text"
    t.string "btn_text_ar"
    t.string "color"
    t.string "text_color"
    t.integer "group"
    t.integer "priority"
    t.json "preferences", default: {}
    t.boolean "is_active", default: true
    t.datetime "start_date", null: false
    t.datetime "end_date", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "keywords"
    t.integer "banner_type", default: 0
    t.index ["end_date"], name: "index_banners_on_end_date"
    t.index ["group"], name: "index_banners_on_group"
    t.index ["is_active"], name: "index_banners_on_is_active"
    t.index ["priority"], name: "index_banners_on_priority"
    t.index ["start_date"], name: "index_banners_on_start_date"
  end

  create_table "banners_retailers", id: false, force: :cascade do |t|
    t.integer "banner_id", null: false
    t.integer "retailer_id", null: false
    t.index ["banner_id"], name: "index_banners_retailers_on_banner_id"
    t.index ["retailer_id"], name: "index_banners_retailers_on_retailer_id"
  end

  create_table "brand_search_keywords", id: :serial, force: :cascade do |t|
    t.string "keywords", null: false
    t.string "product_ids", null: false
    t.datetime "start_date", null: false
    t.datetime "end_date", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["end_date"], name: "index_brand_search_keywords_on_end_date"
    t.index ["keywords"], name: "index_brand_search_keywords_on_keywords"
    t.index ["start_date"], name: "index_brand_search_keywords_on_start_date"
  end

  create_table "brands", id: :serial, force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", default: -> { "now()" }, null: false
    t.datetime "updated_at", default: -> { "now()" }, null: false
    t.string "photo_file_name"
    t.string "photo_content_type"
    t.integer "photo_file_size"
    t.datetime "photo_updated_at"
    t.string "brand_logo_1_file_name"
    t.string "brand_logo_1_content_type"
    t.integer "brand_logo_1_file_size"
    t.datetime "brand_logo_1_updated_at"
    t.string "brand_logo_2_file_name"
    t.string "brand_logo_2_content_type"
    t.integer "brand_logo_2_file_size"
    t.datetime "brand_logo_2_updated_at"
    t.integer "priority"
    t.string "name_ar"
    t.string "slug"
    t.string "group_name"
    t.string "seo_data"
    t.index ["priority"], name: "brands_priority", order: { priority: :desc }
    t.index ["slug"], name: "index_brands_on_slug"
  end

  create_table "brands_promotion_codes", id: false, force: :cascade do |t|
    t.integer "promotion_code_id"
    t.integer "brand_id"
    t.index ["brand_id"], name: "index_brands_promotion_codes_on_brand_id"
    t.index ["promotion_code_id"], name: "index_brands_promotion_codes_on_promotion_code_id"
  end

  create_table "campaigns", force: :cascade do |t|
    t.string "name"
    t.string "name_ar"
    t.datetime "start_time"
    t.datetime "end_time"
    t.integer "priority"
    t.integer "campaign_type"
    t.integer "category_ids", default: [], array: true
    t.integer "subcategory_ids", default: [], array: true
    t.integer "brand_ids", default: [], array: true
    t.integer "retailer_ids", default: [], array: true
    t.integer "store_type_ids", default: [], array: true
    t.integer "retailer_group_ids", default: [], array: true
    t.integer "product_ids", default: [], array: true
    t.integer "locations", default: [], array: true
    t.string "keywords", default: [], array: true
    t.string "url"
    t.string "photo_file_name"
    t.string "photo_content_type"
    t.bigint "photo_file_size"
    t.datetime "photo_updated_at"
    t.string "photo_ar_file_name"
    t.string "photo_ar_content_type"
    t.bigint "photo_ar_file_size"
    t.datetime "photo_ar_updated_at"
    t.string "banner_file_name"
    t.string "banner_content_type"
    t.bigint "banner_file_size"
    t.datetime "banner_updated_at"
    t.string "banner_ar_file_name"
    t.string "banner_ar_content_type"
    t.bigint "banner_ar_file_size"
    t.datetime "banner_ar_updated_at"
    t.string "web_photo_file_name"
    t.string "web_photo_content_type"
    t.bigint "web_photo_file_size"
    t.datetime "web_photo_updated_at"
    t.string "web_photo_ar_file_name"
    t.string "web_photo_ar_content_type"
    t.bigint "web_photo_ar_file_size"
    t.datetime "web_photo_ar_updated_at"
    t.string "web_banner_file_name"
    t.string "web_banner_content_type"
    t.bigint "web_banner_file_size"
    t.datetime "web_banner_updated_at"
    t.string "web_banner_ar_file_name"
    t.string "web_banner_ar_content_type"
    t.bigint "web_banner_ar_file_size"
    t.datetime "web_banner_ar_updated_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "exclude_retailer_ids", default: [], array: true
  end

  create_table "carousel_products", id: :serial, force: :cascade do |t|
    t.string "product_ids", null: false
    t.datetime "start_date", null: false
    t.datetime "end_date", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "categories", id: :serial, force: :cascade do |t|
    t.string "name"
    t.integer "parent_id"
    t.datetime "created_at", default: -> { "now()" }, null: false
    t.datetime "updated_at", default: -> { "now()" }, null: false
    t.string "photo_file_name"
    t.string "photo_content_type"
    t.integer "photo_file_size"
    t.datetime "photo_updated_at"
    t.string "logo_file_name"
    t.string "logo_content_type"
    t.integer "logo_file_size"
    t.datetime "logo_updated_at"
    t.integer "priority"
    t.boolean "is_show_brand", default: false
    t.string "name_ar"
    t.string "description"
    t.string "description_ar"
    t.string "logo1_file_name"
    t.string "logo1_content_type"
    t.integer "logo1_file_size"
    t.datetime "logo1_updated_at"
    t.string "slug"
    t.boolean "is_food"
    t.integer "sale_rank", default: 0
    t.string "message"
    t.string "message_ar"
    t.string "seo_data"
    t.integer "current_tags", default: [], array: true
    t.integer "pickup_priority", default: 0
    t.index ["id", "parent_id", "priority"], name: "categories_idx_id_id_priority"
    t.index ["id", "parent_id"], name: "categories_idx_id_id"
    t.index ["parent_id"], name: "index_categories_on_parent_id"
    t.index ["priority"], name: "index_categories_on_priority"
    t.index ["slug"], name: "index_categories_on_slug"
  end

  create_table "chefs", id: :serial, force: :cascade do |t|
    t.string "name"
    t.string "photo_file_name"
    t.string "photo_content_type"
    t.bigint "photo_file_size"
    t.datetime "photo_updated_at"
    t.string "insta"
    t.string "blog"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "slug"
    t.string "description"
    t.string "seo_data"
    t.string "storyly_slug"
    t.integer "priority"
    t.jsonb "translations", default: {}
  end

  create_table "cities", id: :serial, force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean "is_referral_active"
    t.integer "vat", default: 5
    t.string "slug"
    t.index ["slug"], name: "index_cities_on_slug"
  end

  create_table "cities_referral_rules", id: false, force: :cascade do |t|
    t.integer "city_id", null: false
    t.integer "referral_rule_id", null: false
    t.index ["city_id"], name: "index_cities_referral_rules_on_city_id"
    t.index ["referral_rule_id"], name: "index_cities_referral_rules_on_referral_rule_id"
  end

  create_table "collector_details", id: :serial, force: :cascade do |t|
    t.string "name"
    t.string "phone_number"
    t.integer "shopper_id"
    t.boolean "is_deleted", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "date_time_offset"
  end

  create_table "colors", id: :serial, force: :cascade do |t|
    t.string "name"
    t.string "name_ar"
    t.string "color_code"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "cooking_steps", id: :serial, force: :cascade do |t|
    t.integer "recipe_id"
    t.integer "step_number"
    t.string "step_detail"
    t.integer "time"
    t.string "photo_file_name"
    t.string "photo_content_type"
    t.bigint "photo_file_size"
    t.datetime "photo_updated_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.jsonb "translations", default: {}
  end

  create_table "credit_cards", id: :serial, force: :cascade do |t|
    t.integer "shopper_id"
    t.string "card_type"
    t.string "last4"
    t.string "country"
    t.string "first6"
    t.integer "expiry_month"
    t.integer "expiry_year"
    t.string "trans_ref"
    t.boolean "is_deleted", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "cvv"
    t.string "date_time_offset"
    t.index ["shopper_id"], name: "index_credit_cards_on_shopper_id"
  end

  create_table "csv_imports", id: :serial, force: :cascade do |t|
    t.integer "retailer_id", null: false
    t.integer "admin_id", null: false
    t.string "import_table"
    t.integer "successful_inserts"
    t.integer "failed_inserts"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "csv_import_file_name"
    t.string "csv_import_content_type"
    t.integer "csv_import_file_size"
    t.datetime "csv_import_updated_at"
    t.string "csv_failed_data_file_name"
    t.string "csv_failed_data_content_type"
    t.integer "csv_failed_data_file_size"
    t.datetime "csv_failed_data_updated_at"
    t.string "csv_successful_data_file_name"
    t.string "csv_successful_data_content_type"
    t.integer "csv_successful_data_file_size"
    t.datetime "csv_successful_data_updated_at"
    t.boolean "is_unpublish_other"
    t.string "unpublish_exclude_categories"
    t.index ["admin_id"], name: "index_csv_imports_on_admin_id"
    t.index ["retailer_id"], name: "index_csv_imports_on_retailer_id"
  end

  create_table "data_archives", force: :cascade do |t|
    t.integer "owner_id"
    t.string "owner_type"
    t.jsonb "detail", default: {}
    t.datetime "created_at", null: false
  end

  create_table "delivery_channels", id: :serial, force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "delivery_slots", id: :serial, force: :cascade do |t|
    t.integer "day", null: false
    t.integer "start", null: false
    t.integer "end", null: false
    t.integer "retailer_delivery_zone_id"
    t.integer "orders_limit", default: 0
    t.integer "products_limit", default: 0
    t.integer "products_limit_margin", default: 0
    t.boolean "is_active", default: true
    t.integer "retailer_id"
    t.integer "retailer_service_id"
    t.index ["day"], name: "index_delivery_slots_on_day"
    t.index ["end"], name: "index_delivery_slots_on_end"
    t.index ["orders_limit"], name: "index_delivery_slots_on_orders_limit"
    t.index ["retailer_delivery_zone_id"], name: "index_delivery_slots_on_retailer_delivery_zone_id"
    t.index ["start"], name: "index_delivery_slots_on_start"
  end

  create_table "delivery_zones", id: :serial, force: :cascade do |t|
    t.string "name"
    t.geometry "coordinates", limit: {:srid=>0, :type=>"st_polygon"}
    t.string "description"
    t.string "color"
    t.integer "width"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "kml_file_name"
    t.string "kml_content_type"
    t.integer "kml_file_size"
    t.datetime "kml_updated_at"
    t.index ["coordinates"], name: "index_delivery_zones_on_coordinates", using: :gist
  end

  create_table "email_rules", id: :serial, force: :cascade do |t|
    t.string "name"
    t.integer "days_for"
    t.boolean "is_enable"
    t.string "send_time"
    t.integer "promotion_code_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "category"
  end

  create_table "employee_activities", id: :serial, force: :cascade do |t|
    t.integer "employee_id"
    t.integer "event_id"
    t.integer "order_id"
    t.datetime "created_at", null: false
    t.index ["created_at"], name: "index_employee_activities_on_created_at", order: { created_at: :desc }
  end

  create_table "employee_roles", id: :serial, force: :cascade do |t|
    t.string "name"
  end

  create_table "employees", id: :serial, force: :cascade do |t|
    t.string "user_name", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.string "authentication_token"
    t.string "name"
    t.string "phone_number"
    t.integer "retailer_id"
    t.integer "activity_status"
    t.string "registration_id"
    t.integer "active_roles", default: [], array: true
    t.boolean "is_active", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["reset_password_token"], name: "index_employees_on_reset_password_token", unique: true
    t.index ["user_name"], name: "index_employees_on_user_name", unique: true
  end

  create_table "events", id: :serial, force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "date_time_offset"
  end

  create_table "friendly_id_slugs", id: :serial, force: :cascade do |t|
    t.string "slug", null: false
    t.integer "sluggable_id", null: false
    t.string "sluggable_type", limit: 50
    t.string "scope"
    t.datetime "created_at"
    t.index ["slug", "sluggable_type", "scope"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type_and_scope", unique: true
    t.index ["slug", "sluggable_type"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type"
    t.index ["sluggable_id"], name: "index_friendly_id_slugs_on_sluggable_id"
    t.index ["sluggable_type"], name: "index_friendly_id_slugs_on_sluggable_type"
  end

  create_table "images", force: :cascade do |t|
    t.string "record_type", null: false
    t.integer "record_id", null: false
    t.integer "priority", default: 1
    t.string "photo_file_name"
    t.string "photo_content_type"
    t.bigint "photo_file_size"
    t.datetime "photo_updated_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "ingredients", id: :serial, force: :cascade do |t|
    t.integer "product_id"
    t.float "qty"
    t.string "qty_unit"
    t.integer "recipe_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.jsonb "translations", default: {}
  end

  create_table "locations", id: :serial, force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", default: -> { "now()" }, null: false
    t.datetime "updated_at", default: -> { "now()" }, null: false
    t.integer "city_id"
    t.boolean "active", default: true
    t.integer "primary_location_id"
    t.string "slug"
    t.string "seo_data"
    t.index ["city_id"], name: "index_locations_on_city_id"
    t.index ["name"], name: "index_locations_on_name", unique: true
  end

  create_table "must_stock_lists", id: :serial, force: :cascade do |t|
    t.string "csv_import_file_name"
    t.string "csv_import_content_type"
    t.integer "csv_import_file_size"
    t.datetime "csv_import_updated_at"
    t.string "shop_csv_file_name"
    t.string "shop_csv_content_type"
    t.integer "shop_csv_file_size"
    t.datetime "shop_csv_updated_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "oauth_access_tokens", id: :serial, force: :cascade do |t|
    t.integer "resource_owner_id"
    t.integer "application_id"
    t.string "token", null: false
    t.string "refresh_token"
    t.integer "expires_in"
    t.datetime "revoked_at"
    t.datetime "created_at", null: false
    t.string "scopes"
    t.index ["refresh_token"], name: "index_oauth_access_tokens_on_refresh_token", unique: true
    t.index ["resource_owner_id"], name: "index_oauth_access_tokens_on_resource_owner_id"
    t.index ["token"], name: "index_oauth_access_tokens_on_token", unique: true
  end

  create_table "oauth_applications", id: :serial, force: :cascade do |t|
    t.string "name", null: false
    t.string "uid", null: false
    t.string "secret", null: false
    t.text "redirect_uri", null: false
    t.string "scopes", default: "", null: false
    t.boolean "confidential", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["uid"], name: "index_oauth_applications_on_uid", unique: true
  end

  create_table "online_payment_logs", id: :serial, force: :cascade do |t|
    t.integer "order_id"
    t.string "fort_id"
    t.string "merchant_reference"
    t.float "amount"
    t.string "method"
    t.string "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "authorization_code"
    t.string "date_time_offset"
    t.jsonb "details", default: {}
  end

  create_table "order_allocations", id: :serial, force: :cascade do |t|
    t.integer "order_id"
    t.integer "employee_id"
    t.integer "event_id"
    t.integer "owner_id"
    t.string "owner_type"
    t.boolean "is_active", default: true
    t.datetime "created_at", null: false
    t.index ["created_at"], name: "index_order_allocations_on_created_at", order: { created_at: :desc }
    t.index ["employee_id"], name: "order_allocations_on_employee_id"
    t.index ["is_active"], name: "order_allocations_on_is_active", order: { is_active: :desc }
    t.index ["order_id"], name: "order_allocations_on_order_id"
  end

  create_table "order_collection_details", id: :serial, force: :cascade do |t|
    t.integer "order_id"
    t.integer "collector_detail_id"
    t.integer "vehicle_detail_id"
    t.integer "pickup_location_id"
    t.string "collector_status"
    t.json "events", default: {}
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "date_time_offset"
  end

  create_table "order_feedbacks", id: :serial, force: :cascade do |t|
    t.integer "order_id"
    t.integer "delivery"
    t.integer "speed"
    t.integer "accuracy"
    t.integer "price"
    t.string "comments"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "date_time_offset"
    t.index ["order_id"], name: "index_order_feedbacks_on_order_id"
  end

  create_table "order_positions", id: :serial, force: :cascade do |t|
    t.integer "order_id"
    t.integer "product_id"
    t.integer "amount", null: false
    t.boolean "was_in_shop", default: true
    t.string "product_barcode"
    t.string "product_brand_name"
    t.string "product_name"
    t.string "product_description"
    t.integer "product_shelf_life"
    t.string "product_size_unit"
    t.string "product_country_alpha2"
    t.integer "product_location_id"
    t.string "product_category_name"
    t.string "product_subcategory_name"
    t.integer "shop_price_cents", default: 0, null: false
    t.string "shop_price_currency", default: "AED", null: false
    t.integer "shop_id"
    t.integer "shop_price_dollars", default: 0, null: false
    t.decimal "commission_value", default: "0.0"
    t.integer "category_id"
    t.integer "subcategory_id"
    t.integer "brand_id"
    t.boolean "is_promotional", default: false
    t.decimal "promotional_price", default: "0.0"
    t.string "date_time_offset"
    t.integer "product_proposal_id"
    t.index ["amount"], name: "index_order_positions_on_amount"
    t.index ["brand_id"], name: "index_order_positions_on_brand_id"
    t.index ["category_id"], name: "index_order_positions_on_category_id"
    t.index ["order_id"], name: "index_order_positions_on_order_id"
    t.index ["product_id"], name: "index_order_positions_on_product_id"
    t.index ["shop_id"], name: "index_order_positions_on_shop_id"
    t.index ["subcategory_id"], name: "index_order_positions_on_subcategory_id"
  end

  create_table "order_substitutions", id: :serial, force: :cascade do |t|
    t.integer "order_id"
    t.integer "product_id"
    t.integer "substituting_product_id"
    t.integer "shopper_id"
    t.integer "retailer_id"
    t.boolean "is_selected"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.json "substitute_detail"
    t.integer "shop_promotion_id"
    t.string "date_time_offset"
    t.integer "product_proposal_id"
    t.index ["order_id"], name: "index_orders_on_order_id"
    t.index ["product_id"], name: "index_orders_on_product_id"
  end

  create_table "orders", id: :serial, force: :cascade do |t|
    t.integer "retailer_id"
    t.integer "shopper_id"
    t.datetime "created_at", default: -> { "now()" }
    t.integer "status_id", default: 0
    t.string "retailer_phone_number"
    t.string "retailer_company_name"
    t.string "retailer_opening_time"
    t.string "retailer_company_address"
    t.string "retailer_contact_email"
    t.integer "retailer_delivery_range"
    t.string "shopper_phone_number"
    t.string "shopper_name"
    t.integer "shopper_address_id"
    t.string "shopper_address_area"
    t.string "shopper_address_street"
    t.string "shopper_address_building_name"
    t.string "shopper_address_apartment_number"
    t.datetime "approved_at"
    t.datetime "processed_at"
    t.datetime "accepted_at"
    t.datetime "updated_at"
    t.boolean "is_approved", default: false, null: false
    t.integer "payment_type_id"
    t.string "retailer_contact_person_name"
    t.string "retailer_street"
    t.string "retailer_building"
    t.string "retailer_apartment"
    t.string "retailer_flat_number"
    t.string "retailer_location_name"
    t.integer "retailer_location_id"
    t.string "shopper_address_location_name"
    t.integer "shopper_address_location_id"
    t.float "total_value"
    t.boolean "shopper_deleted", default: false
    t.boolean "retailer_deleted", default: false
    t.string "shopper_address_name"
    t.integer "user_canceled_type"
    t.datetime "canceled_at"
    t.string "message"
    t.text "shopper_note"
    t.decimal "shopper_address_latitude", precision: 10, scale: 8
    t.decimal "shopper_address_longitude", precision: 10, scale: 8
    t.string "shopper_address_location_address"
    t.decimal "wallet_amount_paid"
    t.integer "shopper_address_type_id", default: 1
    t.string "shopper_address_floor"
    t.string "shopper_address_additional_direction"
    t.string "shopper_address_house_number"
    t.integer "delivery_type_id"
    t.integer "delivery_slot_id"
    t.float "delivery_fee"
    t.float "rider_fee"
    t.float "service_fee"
    t.datetime "estimated_delivery_at"
    t.integer "language", default: 0
    t.integer "vat", default: 0
    t.integer "feedback_status", default: 0
    t.integer "device_type"
    t.integer "retailer_delivery_zone_id"
    t.string "hardware_id"
    t.integer "recipe_id"
    t.integer "credit_card_id"
    t.json "card_detail"
    t.float "price_variance", default: 0.0
    t.string "merchant_reference"
    t.string "receipt_no"
    t.float "final_amount"
    t.integer "picker_id"
    t.integer "checkout_person_id"
    t.integer "delivery_person_id"
    t.integer "retailer_service_id", default: 1
    t.integer "delivery_vehicle"
    t.integer "delivery_channel_id", default: 0
    t.string "app_version"
    t.string "date_time_offset"
    t.integer "refunded_amount"
    t.index ["canceled_at"], name: "index_orders_on_canceled_at"
    t.index ["created_at"], name: "index_orders_on_created_at"
    t.index ["credit_card_id"], name: "index_orders_on_credit_card_id"
    t.index ["delivery_slot_id"], name: "index_orders_on_delivery_slot_id"
    t.index ["estimated_delivery_at"], name: "index_orders_on_estimated_delivery_at"
    t.index ["retailer_deleted"], name: "index_shops_on_retailer_deleted"
    t.index ["retailer_id", "id", "created_at"], name: "orders_idx_id_id_at"
    t.index ["retailer_id"], name: "index_orders_on_retailer_id"
    t.index ["shopper_deleted"], name: "index_shops_on_shopper_deleted"
    t.index ["shopper_id"], name: "index_orders_on_shopper_id"
  end

  create_table "orders_data", force: :cascade do |t|
    t.integer "order_id"
    t.jsonb "detail", default: {}
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["order_id"], name: "index_orders_data_on_order_id"
  end

  create_table "partner_configurations", force: :cascade do |t|
    t.string "key"
    t.string "fields"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "partner_integrations", id: :serial, force: :cascade do |t|
    t.integer "retailer_id", null: false
    t.string "api_url", null: false
    t.string "user_name"
    t.string "password"
    t.string "branch_code"
    t.string "api_key"
    t.integer "integration_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "min_stock", default: 1
    t.integer "promotional_min_stock", default: 0
    t.index ["api_url"], name: "index_partner_integrations_on_api_url"
    t.index ["retailer_id"], name: "index_partner_integrations_on_retailer_id"
  end

  create_table "partner_oauth_tokens", force: :cascade do |t|
    t.string "partner_name"
    t.jsonb "detail", default: {}
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "partners", force: :cascade do |t|
    t.string "name"
    t.jsonb "config", default: {}
    t.integer "partner_configuration_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "payment_thresholds", id: :serial, force: :cascade do |t|
    t.integer "order_id"
    t.integer "employee_id"
    t.boolean "is_approved"
    t.string "rejection_reason"
    t.datetime "created_at", null: false
    t.index ["created_at"], name: "index_payment_thresholds_on_created_at", order: { created_at: :desc }
  end

  create_table "permissions", force: :cascade do |t|
    t.string "name"
    t.string "conditions"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "parent_id"
  end

  create_table "pickup_locations", id: :serial, force: :cascade do |t|
    t.integer "retailer_id"
    t.string "details"
    t.string "details_ar"
    t.boolean "is_active", default: true
    t.geography "lonlat", limit: {:srid=>4326, :type=>"st_point", :geographic=>true}
    t.string "photo_file_name"
    t.string "photo_content_type"
    t.bigint "photo_file_size"
    t.datetime "photo_updated_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["lonlat"], name: "index_pickup_locations_on_lonlat", using: :gist
  end

  create_table "product_categories", id: :serial, force: :cascade do |t|
    t.integer "product_id"
    t.integer "category_id"
    t.datetime "created_at", default: -> { "now()" }, null: false
    t.datetime "updated_at", default: -> { "now()" }, null: false
    t.index ["category_id"], name: "index_product_categories_on_category_id"
    t.index ["product_id", "category_id"], name: "product_categories_idx_id_id"
    t.index ["product_id"], name: "index_product_categories_on_product_id"
  end

  create_table "product_csv_imports", id: :serial, force: :cascade do |t|
    t.integer "admin_id", null: false
    t.string "import_table"
    t.string "csv_imports_file_name"
    t.string "csv_imports_content_type"
    t.integer "csv_imports_file_size"
    t.datetime "csv_imports_updated_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "successful_inserts"
    t.integer "failed_inserts"
    t.string "csv_failed_data_file_name"
    t.string "csv_failed_data_content_type"
    t.integer "csv_failed_data_file_size"
    t.datetime "csv_failed_data_updated_at"
    t.string "csv_successful_data_file_name"
    t.string "csv_successful_data_content_type"
    t.integer "csv_successful_data_file_size"
    t.datetime "csv_successful_data_updated_at"
    t.index ["admin_id"], name: "index_product_csv_imports_on_admin_id"
  end

  create_table "product_proposal_categories", force: :cascade do |t|
    t.integer "product_proposal_id"
    t.integer "category_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "product_proposals", force: :cascade do |t|
    t.string "barcode"
    t.string "name"
    t.string "slug"
    t.integer "order_id"
    t.integer "product_id"
    t.integer "retailer_id"
    t.boolean "is_promotion_available", default: false
    t.integer "type_id"
    t.integer "status_id"
    t.float "price"
    t.float "promotional_price"
    t.string "size_unit"
    t.jsonb "details", default: {}
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "product_suggestions", id: :serial, force: :cascade do |t|
    t.string "name"
    t.integer "shopper_id"
    t.integer "retailer_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["retailer_id"], name: "index_product_suggestions_on_retailer_id"
    t.index ["shopper_id"], name: "index_product_suggestions_on_shopper_id"
  end

  create_table "products", id: :serial, force: :cascade do |t|
    t.string "barcode"
    t.integer "brand_id"
    t.datetime "created_at", default: -> { "now()" }, null: false
    t.datetime "updated_at", default: -> { "now()" }, null: false
    t.string "name"
    t.string "description"
    t.string "photo_file_name"
    t.string "photo_content_type"
    t.integer "photo_file_size"
    t.datetime "photo_updated_at"
    t.integer "shelf_life"
    t.string "size_unit"
    t.boolean "is_local"
    t.string "country_alpha2"
    t.integer "location_id"
    t.string "image_external_url"
    t.string "name_ar"
    t.string "description_ar"
    t.string "size_unit_ar"
    t.string "search_keywords", default: ""
    t.string "slug"
    t.integer "category_parent_id"
    t.boolean "is_promotional", default: false
    t.integer "sale_rank", default: 0
    t.index ["barcode"], name: "unique_barcode", unique: true
    t.index ["brand_id"], name: "index_products_on_brand_id"
    t.index ["id", "photo_file_size"], name: "products_idx_id_size"
    t.index ["name"], name: "index_products_on_name"
    t.index ["photo_file_name"], name: "index_products_on_photo_file_name"
    t.index ["photo_file_size"], name: "index_products_on_photo_file_size"
    t.index ["slug"], name: "index_products_on_slug"
  end

  create_table "promotion_code_available_payment_types", id: false, force: :cascade do |t|
    t.integer "promotion_code_id"
    t.integer "available_payment_type_id"
    t.index ["available_payment_type_id"], name: "index_pc_available_payment_types_on_available_payment_type_id"
    t.index ["promotion_code_id"], name: "index_promotion_code_available_payment_types_on_promotion_code_"
  end

  create_table "promotion_code_realizations", id: :serial, force: :cascade do |t|
    t.integer "promotion_code_id"
    t.integer "shopper_id"
    t.integer "order_id"
    t.datetime "realization_date", null: false
    t.integer "retailer_id"
    t.integer "discount_value"
    t.string "date_time_offset"
    t.index ["order_id"], name: "index_promotion_code_realizations_on_order_id"
    t.index ["promotion_code_id"], name: "index_promotion_code_realizations_on_promotion_code_id"
    t.index ["retailer_id"], name: "index_promotion_code_realizations_on_retailer_id"
    t.index ["shopper_id"], name: "index_promotion_code_realizations_on_shopper_id"
  end

  create_table "promotion_codes", id: :serial, force: :cascade do |t|
    t.integer "value_cents", default: 0
    t.string "value_currency", default: "AED"
    t.string "code", null: false
    t.integer "allowed_realizations", default: 1
    t.date "start_date"
    t.date "end_date"
    t.integer "realizations_per_shopper", default: 1
    t.integer "realizations_per_retailer", default: 1
    t.decimal "min_basket_value", default: "0.0"
    t.string "order_limit", default: "0-1000"
    t.boolean "all_brands", default: false
    t.boolean "all_retailers", default: false
    t.integer "shopper_ids", default: [], array: true
    t.float "percentage_off"
    t.integer "retailer_service_id"
    t.string "reference"
    t.integer "promotion_type", default: 4
    t.jsonb "data", default: {}
    t.index ["retailer_service_id"], name: "index_promotion_codes_on_retailer_service_id"
  end

  create_table "promotion_codes_retailers", id: false, force: :cascade do |t|
    t.integer "promotion_code_id"
    t.integer "retailer_id"
    t.index ["promotion_code_id"], name: "index_promotion_codes_retailers_on_promotion_code_id"
    t.index ["retailer_id"], name: "index_promotion_codes_retailers_on_retailer_id"
  end

  create_table "recipe_categories", id: :serial, force: :cascade do |t|
    t.string "name"
    t.integer "parent_id"
    t.string "photo_file_name"
    t.string "photo_content_type"
    t.bigint "photo_file_size"
    t.datetime "photo_updated_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "slug"
    t.string "description"
    t.string "seo_data"
    t.jsonb "translations", default: {}
  end

  create_table "recipes", id: :serial, force: :cascade do |t|
    t.string "name"
    t.string "photo_file_name"
    t.string "photo_content_type"
    t.bigint "photo_file_size"
    t.datetime "photo_updated_at"
    t.integer "recipe_category_id"
    t.integer "prep_time"
    t.integer "cook_time"
    t.string "description"
    t.integer "chef_id"
    t.integer "for_people"
    t.boolean "is_published"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "deep_link"
    t.string "slug"
    t.string "seo_data"
    t.string "storyly_slug"
    t.integer "priority"
    t.integer "retailer_ids", default: [], array: true
    t.integer "retailer_group_ids", default: [], array: true
    t.integer "store_type_ids", default: [], array: true
    t.jsonb "translations", default: {}
    t.integer "exclude_retailer_ids", default: [], array: true
  end

  create_table "recipes_categories", id: false, force: :cascade do |t|
    t.integer "recipe_id"
    t.integer "recipe_category_id"
  end

  create_table "referral_rules", id: :serial, force: :cascade do |t|
    t.string "name"
    t.integer "expiry_days"
    t.integer "referrer_amount"
    t.integer "referee_amount"
    t.integer "event_id"
    t.text "message"
    t.boolean "is_active"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "message_ar"
    t.index ["event_id"], name: "index_referral_rules_on_available_payment_event_id"
    t.index ["is_active"], name: "index_referral_rules_on_available_payment_is_active"
  end

  create_table "referral_wallet_realizations", id: :serial, force: :cascade do |t|
    t.integer "referral_wallet_id"
    t.integer "order_id"
    t.decimal "amount_used"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["order_id"], name: "index_referral_wallet_realizations_on_order_id"
    t.index ["referral_wallet_id"], name: "index_referral_wallet_realizations_on_referral_wallet_id"
  end

  create_table "referral_wallets", id: :serial, force: :cascade do |t|
    t.integer "shopper_id"
    t.integer "amount"
    t.datetime "expire_date"
    t.string "info"
    t.integer "referral_rule_id"
    t.integer "order_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.decimal "remaining_credit"
    t.index ["order_id"], name: "index_referral_wallets_on_order_id"
    t.index ["referral_rule_id"], name: "index_referral_wallets_on_referral_rule_id"
    t.index ["shopper_id"], name: "index_referral_wallets_on_shopper_id"
  end

  create_table "retailer_categories", id: false, force: :cascade do |t|
    t.integer "retailer_id"
    t.integer "category_id"
    t.index ["category_id"], name: "index_retailer_categories_on_category_id"
    t.index ["retailer_id", "category_id"], name: "retailer_categories_idx_id"
    t.index ["retailer_id"], name: "index_retailer_categories_on_retailer_id"
  end

  create_table "retailer_delivery_zones", id: :serial, force: :cascade do |t|
    t.integer "retailer_id"
    t.integer "delivery_zone_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.decimal "min_basket_value", default: "0.0"
    t.float "delivery_fee", default: 0.0
    t.float "rider_fee", default: 0.0
    t.integer "delivery_slot_skip_time", default: 0
    t.integer "cutoff_time", default: 0
    t.integer "delivery_type"
    t.index ["delivery_zone_id"], name: "index_retailer_delivery_zones_on_delivery_zone_id"
    t.index ["retailer_id"], name: "index_retailer_delivery_zones_on_retailer_id"
  end

  create_table "retailer_groups", id: :serial, force: :cascade do |t|
    t.string "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.float "online_payment_charge", default: 0.0
  end

  create_table "retailer_has_available_payment_types", id: :serial, force: :cascade do |t|
    t.integer "retailer_id"
    t.integer "available_payment_type_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "retailer_service_id"
    t.boolean "accept_promocode", default: true
    t.index ["available_payment_type_id"], name: "index_retailer_has_available_payment_types_on_available_payment"
    t.index ["retailer_id"], name: "index_retailer_has_available_payment_types_on_retailer_id"
  end

  create_table "retailer_has_locations", id: :serial, force: :cascade do |t|
    t.integer "retailer_id", null: false
    t.integer "location_id", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal "min_basket_value", default: "0.0"
    t.index ["location_id"], name: "index_retailer_has_locations_on_location_id"
    t.index ["retailer_id"], name: "index_retailer_has_locations_on_retailer_id"
  end

  create_table "retailer_has_services", id: :serial, force: :cascade do |t|
    t.integer "retailer_id"
    t.integer "retailer_service_id"
    t.integer "cutoff_time", default: 0
    t.float "service_fee", default: 0.0
    t.float "min_basket_value", default: 0.0
    t.integer "delivery_slot_skip_time", default: 0
    t.boolean "is_active", default: false
    t.integer "schedule_order_reminder_time", default: 3600
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "delivery_type"
  end

  create_table "retailer_opening_hours", id: :serial, force: :cascade do |t|
    t.integer "retailer_id", null: false
    t.integer "day", null: false
    t.integer "open", null: false
    t.integer "close", null: false
    t.integer "retailer_delivery_zone_id"
    t.index ["retailer_delivery_zone_id"], name: "index_retailer_opening_hours_on_retailer_delivery_zone_id"
    t.index ["retailer_id"], name: "index_retailer_opening_hours_on_retailer_id"
  end

  create_table "retailer_operators", id: :serial, force: :cascade do |t|
    t.integer "retailer_id"
    t.string "hardware_id"
    t.string "registration_id"
    t.integer "device_type"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["retailer_id"], name: "index_retailer_operators_on_retailer_id"
  end

  create_table "retailer_reports", id: :serial, force: :cascade do |t|
    t.string "name"
    t.integer "retailer_id"
    t.integer "export_total"
    t.datetime "from_date"
    t.datetime "to_date"
    t.string "file1_file_name"
    t.string "file1_content_type"
    t.integer "file1_file_size"
    t.datetime "file1_updated_at"
    t.string "file2_file_name"
    t.string "file2_content_type"
    t.integer "file2_file_size"
    t.datetime "file2_updated_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "excel_file_name"
    t.string "excel_content_type"
    t.integer "excel_file_size"
    t.datetime "excel_updated_at"
  end

  create_table "retailer_reviews", id: :serial, force: :cascade do |t|
    t.integer "retailer_id"
    t.integer "overall_rating"
    t.integer "delivery_speed_rating"
    t.integer "order_accuracy_rating"
    t.integer "quality_rating"
    t.integer "price_rating"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text "comment"
    t.integer "shopper_id", null: false
    t.index ["retailer_id"], name: "index_retailer_reviews_on_retailer_id"
  end

  create_table "retailer_services", id: :serial, force: :cascade do |t|
    t.string "name"
    t.float "search_radius"
    t.float "availability_radius"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "retailer_store_types", id: false, force: :cascade do |t|
    t.integer "retailer_id"
    t.integer "store_type_id"
    t.index ["retailer_id"], name: "index_retailer_store_types_on_retailer_id"
    t.index ["store_type_id"], name: "index_retailer_store_types_on_store_type_id"
  end

  create_table "retailer_types", force: :cascade do |t|
    t.string "name"
    t.string "description"
    t.string "bg_color", default: "#00FFFFFF"
    t.integer "priority"
    t.jsonb "translations", default: {}
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "retailers", id: :serial, force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet "current_sign_in_ip"
    t.inet "last_sign_in_ip"
    t.string "authentication_token"
    t.string "phone_number", default: "", null: false
    t.string "company_name", default: "", null: false
    t.string "opening_time", default: "", null: false
    t.string "company_address", default: "", null: false
    t.string "contact_email", default: "", null: false
    t.integer "delivery_range", default: 0, null: false
    t.datetime "created_at", default: -> { "now()" }
    t.datetime "updated_at", default: -> { "now()" }
    t.decimal "latitude", precision: 11, scale: 8
    t.decimal "longitude", precision: 11, scale: 8
    t.string "photo_file_name"
    t.string "photo_content_type"
    t.integer "photo_file_size"
    t.datetime "photo_updated_at"
    t.boolean "is_active", default: true
    t.string "contact_person_name"
    t.string "street"
    t.string "building"
    t.string "apartment"
    t.string "flat_number"
    t.integer "location_id"
    t.string "registration_id"
    t.integer "device_type"
    t.integer "delivery_team_commitment"
    t.integer "number_of_deliveries_per_hour_commitment"
    t.string "store_owner_name"
    t.string "store_owner_phone_number"
    t.string "store_owner_email"
    t.string "store_manager_name"
    t.string "store_manager_phone_number"
    t.string "store_manager_email"
    t.string "integration_level"
    t.text "notes"
    t.text "delivery_notes"
    t.integer "available_payment_type_id"
    t.boolean "is_opened", default: true
    t.decimal "commission_value", default: "0.0"
    t.integer "priority"
    t.boolean "is_generate_report", default: false
    t.boolean "is_report_add_email", default: false
    t.boolean "is_report_add_phone", default: false
    t.string "report_emails"
    t.integer "report_parent_id"
    t.boolean "is_show_brand", default: true
    t.integer "delivery_type_id", default: 0
    t.integer "delivery_slot_skip_hours", default: 14400
    t.integer "schedule_order_reminder_hours", default: 3600
    t.float "service_fee", default: 0.0
    t.string "company_name_ar"
    t.string "company_address_ar"
    t.string "photo1_file_name"
    t.string "photo1_content_type"
    t.integer "photo1_file_size"
    t.datetime "photo1_updated_at"
    t.string "slug"
    t.boolean "is_show_recipe", default: false
    t.integer "cutoff_time", default: 0
    t.integer "retailer_type", default: 0
    t.integer "show_pending_order_hours", default: 0
    t.integer "retailer_group_id"
    t.string "seo_data"
    t.string "date_time_offset"
    t.boolean "with_stock_level", default: false
    t.boolean "is_featured", default: false
    t.boolean "send_tax_invoice", default: false
    t.index ["authentication_token"], name: "index_retailers_on_authentication_token", unique: true
    t.index ["email"], name: "index_retailers_on_email", unique: true
    t.index ["reset_password_token"], name: "index_retailers_on_reset_password_token", unique: true
    t.index ["slug"], name: "index_retailers_on_slug"
  end

  create_table "role_permissions", force: :cascade do |t|
    t.bigint "role_id"
    t.bigint "permission_id"
    t.string "can_create", default: ""
    t.string "can_read", default: ""
    t.string "can_update", default: ""
    t.string "can_delete", default: ""
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["permission_id"], name: "index_role_permissions_on_permission_id"
    t.index ["role_id"], name: "index_role_permissions_on_role_id"
  end

  create_table "roles", force: :cascade do |t|
    t.string "name"
    t.integer "retailer_group_ids", default: [], array: true
    t.integer "city_ids", default: [], array: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "rpush_apps", id: :serial, force: :cascade do |t|
    t.string "name", null: false
    t.string "environment"
    t.text "certificate"
    t.string "password"
    t.integer "connections", default: 1, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "type", null: false
    t.string "auth_key"
    t.string "client_id"
    t.string "client_secret"
    t.string "access_token"
    t.datetime "access_token_expiration"
  end

  create_table "rpush_feedback", id: :serial, force: :cascade do |t|
    t.string "device_token", limit: 64, null: false
    t.datetime "failed_at", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "app_id"
    t.index ["device_token"], name: "index_rpush_feedback_on_device_token"
  end

  create_table "rpush_notifications", id: :serial, force: :cascade do |t|
    t.integer "badge"
    t.string "device_token", limit: 64
    t.string "sound", default: "default"
    t.string "alert"
    t.text "data"
    t.integer "expiry", default: 86400
    t.boolean "delivered", default: false, null: false
    t.datetime "delivered_at"
    t.boolean "failed", default: false, null: false
    t.datetime "failed_at"
    t.integer "error_code"
    t.text "error_description"
    t.datetime "deliver_after"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean "alert_is_json", default: false
    t.string "type", null: false
    t.string "collapse_key"
    t.boolean "delay_while_idle", default: false, null: false
    t.text "registration_ids"
    t.integer "app_id", null: false
    t.integer "retries", default: 0
    t.string "uri"
    t.datetime "fail_after"
    t.boolean "processing", default: false, null: false
    t.integer "priority"
    t.text "url_args"
    t.string "category"
    t.index ["delivered", "failed"], name: "index_rpush_notifications_multi", where: "((NOT delivered) AND (NOT failed))"
  end

  create_table "screen_products", id: :serial, force: :cascade do |t|
    t.integer "screen_id"
    t.integer "product_id"
    t.integer "priority"
  end

  create_table "screen_retailers", id: false, force: :cascade do |t|
    t.integer "screen_id"
    t.integer "retailer_id"
  end

  create_table "screens", id: :serial, force: :cascade do |t|
    t.string "name"
    t.integer "priority"
    t.integer "group"
    t.boolean "is_active", default: true
    t.string "photo_file_name"
    t.string "photo_content_type"
    t.bigint "photo_file_size"
    t.datetime "photo_updated_at"
    t.string "photo_ar_file_name"
    t.string "photo_ar_content_type"
    t.bigint "photo_ar_file_size"
    t.datetime "photo_ar_updated_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "banner_photo_file_name"
    t.string "banner_photo_content_type"
    t.bigint "banner_photo_file_size"
    t.datetime "banner_photo_updated_at"
    t.string "banner_photo_ar_file_name"
    t.string "banner_photo_ar_content_type"
    t.bigint "banner_photo_ar_file_size"
    t.datetime "banner_photo_ar_updated_at"
    t.integer "locations", default: [], array: true
    t.datetime "start_date"
    t.datetime "end_date"
    t.integer "store_types", default: [], array: true
    t.integer "retailer_groups", default: [], array: true
    t.integer "retailer_ids", default: [], array: true
  end

  create_table "searchjoy_searches", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.string "search_type"
    t.string "query"
    t.string "normalized_query"
    t.integer "results_count"
    t.datetime "created_at"
    t.integer "convertable_id"
    t.string "convertable_type"
    t.datetime "converted_at"
    t.integer "retailer_id"
    t.string "language"
    t.index ["created_at"], name: "index_searchjoy_searches_on_created_at"
  end

  create_table "settings", id: :serial, force: :cascade do |t|
    t.boolean "enable_es_search", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "order_accept_duration", default: 15
    t.integer "order_enroute_duration", default: 30
    t.integer "order_delivered_duration", default: 60
    t.integer "product_rank_days", default: 30
    t.integer "product_rank_orders_limit", default: 10
    t.datetime "product_rank_date"
    t.datetime "product_derank_date"
    t.binary "apn_certificate"
    t.string "feedback_duration"
    t.integer "product_most_selling_days", default: 30
    t.integer "product_trending_days", default: 7
    t.string "ios_version"
    t.string "android_version"
    t.string "web_version"
  end

  create_table "shop_product_logs", id: :serial, force: :cascade do |t|
    t.integer "order_id"
    t.integer "retailer_id"
    t.integer "product_id"
    t.integer "category_id"
    t.integer "subcategory_id"
    t.integer "brand_id"
    t.string "retailer_name"
    t.string "product_name"
    t.string "category_name"
    t.string "brand_name"
    t.string "subcategory_name"
    t.boolean "is_published"
    t.boolean "is_available"
    t.integer "owner_id"
    t.string "owner_type"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.float "price"
  end

  create_table "shop_product_rule_categories", id: :serial, force: :cascade do |t|
    t.integer "shop_product_rule_id"
    t.integer "category_id"
  end

  create_table "shop_product_rule_retailers", id: false, force: :cascade do |t|
    t.integer "shop_product_rule_id"
    t.integer "retailer_id"
  end

  create_table "shop_product_rules", id: :serial, force: :cascade do |t|
    t.integer "at_day"
    t.string "at_time"
    t.boolean "is_enable", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "shop_promotions", force: :cascade do |t|
    t.integer "product_id", null: false
    t.integer "retailer_id", null: false
    t.float "price", default: 0.0
    t.integer "product_limit", default: 0
    t.float "start_time"
    t.float "end_time"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "price_currency", default: "AED", null: false
    t.float "standard_price", default: 0.0
    t.boolean "is_active", default: true
  end

  create_table "shopper_addresses", id: :serial, force: :cascade do |t|
    t.integer "shopper_id"
    t.string "address_name"
    t.string "area"
    t.string "street"
    t.string "building_name"
    t.string "apartment_number"
    t.datetime "created_at", default: -> { "now()" }
    t.integer "location_id"
    t.boolean "default_address", default: false
    t.geography "lonlat", limit: {:srid=>4326, :type=>"st_point", :geographic=>true}
    t.string "location_address"
    t.string "street_address"
    t.string "street_number"
    t.string "route"
    t.string "country"
    t.string "administrative_area_level_1"
    t.string "locality"
    t.string "sublocality"
    t.string "neighborhood"
    t.string "premise"
    t.integer "address_type_id", default: 1
    t.string "floor"
    t.string "additional_direction"
    t.string "house_number"
    t.string "phone_number"
    t.string "shopper_name"
    t.integer "address_tag_id"
    t.string "date_time_offset"
    t.index ["lonlat"], name: "index_shopper_addresses_on_lonlat", using: :gist
    t.index ["shopper_id"], name: "index_shopper_addresses_on_shopper_id"
  end

  create_table "shopper_agreements", id: :serial, force: :cascade do |t|
    t.integer "shopper_id"
    t.boolean "accepted"
    t.text "agreement"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "date_time_offset"
  end

  create_table "shopper_cart_products", id: :serial, force: :cascade do |t|
    t.integer "shopper_id"
    t.integer "retailer_id"
    t.integer "product_id"
    t.integer "quantity"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "shop_id"
    t.integer "shop_promotion_id"
    t.float "delivery_time"
    t.string "date_time_offset"
    t.index ["product_id"], name: "index_shopper_cart_products_on_product_id"
    t.index ["quantity"], name: "index_shopper_cart_products_on_quantity"
    t.index ["retailer_id"], name: "index_shopper_cart_products_on_retailer_id"
    t.index ["shopper_id"], name: "index_shopper_cart_products_on_shopper_id"
  end

  create_table "shopper_favourite_products", id: :serial, force: :cascade do |t|
    t.integer "product_id"
    t.integer "shopper_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["product_id"], name: "index_shopper_favourite_products_on_product_id"
    t.index ["shopper_id"], name: "index_shopper_favourite_products_on_shopper_id"
  end

  create_table "shopper_favourite_retailers", id: :serial, force: :cascade do |t|
    t.integer "retailer_id"
    t.integer "shopper_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["retailer_id"], name: "index_shopper_favourite_retailers_on_retailer_id"
    t.index ["shopper_id"], name: "index_shopper_favourite_retailers_on_shopper_id"
  end

  create_table "shopper_recipes", force: :cascade do |t|
    t.integer "shopper_id"
    t.integer "recipe_id"
    t.string "date_time_offset"
  end

  create_table "shoppers", id: :serial, force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet "current_sign_in_ip"
    t.inet "last_sign_in_ip"
    t.string "phone_number", default: ""
    t.string "name", default: ""
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "authentication_token"
    t.string "invoice_city"
    t.string "invoice_street"
    t.string "invoice_building_name"
    t.string "invoice_apartment_number"
    t.integer "invoice_floor_number"
    t.integer "invoice_location_id"
    t.string "registration_id"
    t.integer "device_type"
    t.string "referral_code"
    t.integer "referred_by"
    t.integer "language", default: 0
    t.string "app_version"
    t.boolean "is_blocked", default: false
    t.string "date_time_offset"
    t.string "smiles_loyalty_id"
    t.string "unique_smiles_token"
    t.integer "retry_otp_attempts", default: 0, null: false
    t.integer "invalid_otp_count", default: 0, null: false
    t.boolean "is_smiles_user", default: false
    t.index "lower((email)::text)", name: "email_lower_idx", unique: true
    t.index "upper((email)::text)", name: "email_upper_idx", unique: true
    t.index ["authentication_token"], name: "index_shoppers_on_authentication_token", unique: true
    t.index ["email"], name: "index_shoppers_on_email", unique: true
    t.index ["reset_password_token"], name: "index_shoppers_on_reset_password_token", unique: true
  end

  create_table "shoppers_data", force: :cascade do |t|
    t.integer "shopper_id"
    t.jsonb "detail", default: {}
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "shops", id: :serial, force: :cascade do |t|
    t.integer "retailer_id"
    t.integer "product_id"
    t.datetime "created_at", default: -> { "now()" }, null: false
    t.datetime "updated_at", default: -> { "now()" }, null: false
    t.integer "price_cents", default: 0, null: false
    t.string "price_currency", default: "AED", null: false
    t.integer "price_dollars", default: 0, null: false
    t.decimal "commission_value"
    t.decimal "product_rank", default: "0.0"
    t.boolean "is_published", default: true
    t.boolean "is_available", default: true
    t.boolean "is_promotional", default: false
    t.jsonb "detail", default: {}
    t.boolean "promotion_only", default: false
    t.integer "stock_on_hand"
    t.integer "available_for_sale"
    t.index ["is_available"], name: "index_shops_on_is_available", order: { is_available: :desc }
    t.index ["is_published"], name: "index_shops_on_is_published", order: { is_published: :desc }
    t.index ["product_id"], name: "index_shops_on_product_id"
    t.index ["product_rank"], name: "index_shops_on_product_rank", order: { product_rank: :desc }
    t.index ["retailer_id", "product_id"], name: "unique_product", unique: true
    t.index ["retailer_id"], name: "index_shops_on_retailer_id"
  end

  create_table "smiles_transaction_logs", force: :cascade do |t|
    t.string "event"
    t.string "transaction_id"
    t.integer "order_id"
    t.integer "shopper_id"
    t.string "conversion_rule"
    t.jsonb "details", default: {}
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "transaction_ref_id"
    t.float "transaction_amount"
  end

  create_table "store_types", id: :serial, force: :cascade do |t|
    t.string "name"
    t.string "name_ar"
    t.integer "priority"
    t.string "photo_file_name"
    t.string "photo_content_type"
    t.bigint "photo_file_size"
    t.datetime "photo_updated_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "bg_color", default: "#00FFFFFF"
  end

  create_table "substitution_preferences", id: :serial, force: :cascade do |t|
    t.integer "category_id"
    t.float "brand_priority"
    t.float "size_priority"
    t.float "price_priority"
    t.float "flavour_priority"
    t.integer "min_match"
    t.integer "shopper_id"
    t.index ["category_id"], name: "index_substitution_preferences_on_category_id"
  end

  create_table "system_configurations", id: :serial, force: :cascade do |t|
    t.string "key"
    t.string "value"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "vehicle_details", id: :serial, force: :cascade do |t|
    t.string "plate_number"
    t.integer "vehicle_model_id"
    t.integer "color_id"
    t.string "company"
    t.integer "collector_id"
    t.boolean "is_deleted", default: false
    t.integer "shopper_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "date_time_offset"
    t.index ["collector_id"], name: "index_vehicle_details_on_collector_id"
    t.index ["color_id"], name: "index_vehicle_details_on_color_id"
    t.index ["is_deleted"], name: "index_vehicle_details_on_is_deleted"
    t.index ["shopper_id"], name: "index_vehicle_details_on_shopper_id"
    t.index ["vehicle_model_id"], name: "index_vehicle_details_on_vehicle_model_id"
  end

  create_table "vehicle_models", id: :serial, force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "versions", id: :serial, force: :cascade do |t|
    t.integer "majorversion", null: false
    t.integer "minorversion", null: false
    t.integer "revision", null: false
    t.integer "devise_type"
    t.integer "action", default: 0, null: false
    t.string "message"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["devise_type"], name: "index_versions_on_devise_type"
    t.index ["majorversion", "minorversion"], name: "index_versions_on_major_and_moinorversion", order: { majorversion: :desc, minorversion: :desc }
  end

  add_foreign_key "credit_cards", "shoppers"
  add_foreign_key "locations", "cities"
  add_foreign_key "oauth_access_tokens", "oauth_applications", column: "application_id"
  add_foreign_key "orders", "credit_cards"
  add_foreign_key "referral_wallet_realizations", "orders"
  add_foreign_key "referral_wallet_realizations", "referral_wallets"
  add_foreign_key "referral_wallets", "orders"
  add_foreign_key "referral_wallets", "referral_rules"
  add_foreign_key "referral_wallets", "shoppers"
  add_foreign_key "retailer_delivery_zones", "delivery_zones"
  add_foreign_key "retailer_delivery_zones", "retailers"
  add_foreign_key "role_permissions", "permissions"
  add_foreign_key "role_permissions", "roles"
  add_foreign_key "shops", "retailers"

  create_view "delivery_slots_capacity_mv", materialized: true, sql_definition: <<-SQL
      SELECT ds.retailer_id,
      ((sum(ds.products_limit) * min(ds.products_limit)) / GREATEST(min(ds.products_limit), 1)) AS total_limit,
      sum(ds.products_limit_margin) AS total_margin,
      ((sum(ds.orders_limit) * min(ds.orders_limit)) / GREATEST(min(ds.orders_limit), 1)) AS total_orders_limit,
      ds.start AS dsstart,
      ds.day AS dsday,
      ds.retailer_service_id
     FROM delivery_slots ds,
      retailers r
    WHERE ((ds.retailer_id = r.id) AND (ds.is_active = true) AND (r.is_active = true) AND (r.is_opened = true))
    GROUP BY ds.retailer_id, ds.start, ds.day, ds.retailer_service_id
    ORDER BY ds.retailer_id, ds.day, ds.start;
  SQL
  add_index "delivery_slots_capacity_mv", ["retailer_id"], name: "retailer_id_on_delivery_slots_capacity_mv"

  create_view "available_slots", sql_definition: <<-SQL
      SELECT delivery_slots.id,
      dense_rank() OVER (PARTITION BY delivery_slots.retailer_service_id, delivery_slots.retailer_id, delivery_slots.retailer_delivery_zone_id ORDER BY (ts.dates + ((delivery_slots.start)::double precision * '00:00:01'::interval))) AS slot_rank,
      concat(date_part('year'::text, ts.dates), lpad((date_part('week'::text, (ts.dates + '1 day'::interval)))::text, 2, '0'::text), delivery_slots.id) AS usid,
      delivery_slots.day,
      delivery_slots.start,
      delivery_slots."end",
      delivery_slots.retailer_delivery_zone_id,
      delivery_slots.orders_limit,
      delivery_slots.products_limit,
      delivery_slots.products_limit_margin,
      delivery_slots.retailer_id,
      delivery_slots.retailer_service_id,
      (ts.dates + ((ds.start)::double precision * '00:00:01'::interval)) AS slot_date,
      COALESCE(sum(order_positions.amount), (0)::bigint) AS total_products,
      totals.total_limit,
      totals.total_margin,
      count(DISTINCT orders.id) AS total_orders,
      totals.total_orders_limit,
      date_part('week'::text, (ts.dates + '1 day'::interval)) AS week,
      r.cutoff_time,
      r.delivery_slot_skip_hours
     FROM ((((((((delivery_slots
       JOIN ( SELECT (CURRENT_DATE + s.a) AS dates,
              (date_part('dow'::text, (CURRENT_DATE + s.a)) + (1)::double precision) AS wday
             FROM generate_series(0, 7, 1) s(a)) ts ON ((ts.wday = (delivery_slots.day)::double precision)))
       JOIN retailers r ON ((delivery_slots.retailer_id = r.id)))
       JOIN retailer_has_services rhs ON (((rhs.retailer_service_id = delivery_slots.retailer_service_id) AND (rhs.retailer_id = r.id))))
       JOIN delivery_slots_capacity_mv totals ON (((totals.dsstart = delivery_slots.start) AND (totals.dsday = delivery_slots.day) AND (totals.retailer_id = delivery_slots.retailer_id) AND (totals.retailer_service_id = delivery_slots.retailer_service_id))))
       JOIN delivery_slots ds ON (((ds.start = delivery_slots.start) AND (ds.day = delivery_slots.day) AND (ds.retailer_id = delivery_slots.retailer_id) AND (ds.retailer_service_id = delivery_slots.retailer_service_id))))
       LEFT JOIN retailer_delivery_zones rdz ON ((rdz.id = delivery_slots.retailer_delivery_zone_id)))
       LEFT JOIN orders ON (((orders.delivery_slot_id = ds.id) AND (orders.status_id <> ALL (ARRAY['-1'::integer, 4])) AND (date(orders.estimated_delivery_at) = ts.dates))))
       LEFT JOIN order_positions ON ((order_positions.order_id = orders.id)))
    WHERE ((delivery_slots.is_active = true) AND ((ts.dates + ((ds.start)::double precision * '00:00:01'::interval)) > ((CURRENT_TIMESTAMP + ((
          CASE
              WHEN (delivery_slots.retailer_service_id = 1) THEN rdz.delivery_slot_skip_time
              ELSE rhs.delivery_slot_skip_time
          END)::double precision * '00:00:01'::interval)) +
          CASE
              WHEN (
              CASE
                  WHEN (delivery_slots.retailer_service_id = 1) THEN rdz.cutoff_time
                  ELSE rhs.cutoff_time
              END > 0) THEN
              CASE
                  WHEN (date_part('epoch'::text, (CURRENT_TIMESTAMP)::time without time zone) > (
                  CASE
                      WHEN (delivery_slots.retailer_service_id = 1) THEN rdz.cutoff_time
                      ELSE rhs.cutoff_time
                  END)::double precision) THEN ((((CURRENT_TIMESTAMP)::date + 2))::timestamp with time zone - CURRENT_TIMESTAMP)
                  ELSE ((((CURRENT_TIMESTAMP)::date + 1))::timestamp with time zone - CURRENT_TIMESTAMP)
              END
              ELSE '00:00:00'::interval
          END)))
    GROUP BY delivery_slots.id, r.id, totals.total_limit, totals.total_margin, totals.total_orders_limit, ts.dates, ((ds.start)::double precision * '00:00:01'::interval)
   HAVING (((totals.total_orders_limit = 0) OR (totals.total_orders_limit > count(DISTINCT orders.id))) AND ((totals.total_limit = 0) OR ((totals.total_limit > COALESCE(sum(order_positions.amount), (0)::bigint)) AND ((((COALESCE(sum(order_positions.amount), (0)::bigint))::numeric / ((totals.total_limit)::numeric * 1.0)) <= 0.7) OR ((totals.total_limit + totals.total_margin) >= (COALESCE(sum(order_positions.amount), (0)::bigint) + 0))))))
    ORDER BY ts.dates, delivery_slots.day, delivery_slots.start;
  SQL
  create_view "available_slots_mv", materialized: true, sql_definition: <<-SQL
      SELECT available_slots.id,
      available_slots.slot_rank,
      available_slots.usid,
      available_slots.day,
      available_slots.start,
      available_slots."end",
      available_slots.retailer_delivery_zone_id,
      available_slots.orders_limit,
      available_slots.products_limit,
      available_slots.products_limit_margin,
      available_slots.retailer_id,
      available_slots.retailer_service_id,
      available_slots.slot_date,
      available_slots.total_products,
      available_slots.total_limit,
      available_slots.total_margin,
      available_slots.total_orders,
      available_slots.total_orders_limit,
      available_slots.week,
      available_slots.cutoff_time,
      available_slots.delivery_slot_skip_hours
     FROM available_slots;
  SQL
  add_index "available_slots_mv", ["retailer_delivery_zone_id"], name: "retailer_delivery_zone_id_on_available_slots_mv"
  add_index "available_slots_mv", ["retailer_id"], name: "retailer_id_on_available_slots_mv"
  add_index "available_slots_mv", ["usid"], name: "index_available_slots_mv", unique: true

  create_view "payfort_events", sql_definition: <<-SQL
      SELECT jd.id,
      jd.event_id,
      jd.created_at,
      jd.owner_id,
      jd.owner_type,
      jd.jdetail,
      (jd.jdetail ->> 'merchant_reference'::text) AS merchant_reference,
      (jd.jdetail ->> 'fort_id'::text) AS fort_id,
      (jd.jdetail ->> 'command'::text) AS command,
      (jd.jdetail ->> 'response_message'::text) AS response_message,
      (jd.jdetail ->> 'authorization_code'::text) AS authorization_code,
      (jd.jdetail ->> 'card_number'::text) AS card_number,
      (jd.jdetail ->> 'customer_ip'::text) AS customer_ip,
      (jd.jdetail ->> 'customer_email'::text) AS customer_email,
      (jd.jdetail ->> 'amount'::text) AS amount
     FROM ( SELECT t.id,
              t.event_id,
              t.created_at,
              t.owner_id,
              t.owner_type,
              (replace((t.detail)::text, '=>'::text, ':'::text))::jsonb AS jdetail
             FROM ( SELECT analytics.id,
                      analytics.event_id,
                      analytics.created_at,
                      analytics.updated_at,
                      analytics.owner_id,
                      analytics.owner_type,
                      analytics.detail,
                      row_number() OVER (PARTITION BY analytics.detail ORDER BY analytics.id) AS row_num
                     FROM analytics
                    WHERE ((analytics.detail)::text ~ 'merchant_reference'::text)) t
            WHERE (t.row_num = 1)) jd;
  SQL
  create_view "campaign_brands", sql_definition: <<-SQL
      SELECT campaigns.id AS campaign_id,
      brand_id.brand_id
     FROM campaigns,
      LATERAL unnest(campaigns.brand_ids) brand_id(brand_id);
  SQL
  create_view "campaign_categories", sql_definition: <<-SQL
      SELECT campaigns.id AS campaign_id,
      category_id.category_id
     FROM campaigns,
      LATERAL unnest(campaigns.category_ids) category_id(category_id);
  SQL
  create_view "campaign_subcategories", sql_definition: <<-SQL
      SELECT campaigns.id AS campaign_id,
      category_id.category_id
     FROM campaigns,
      LATERAL unnest(campaigns.subcategory_ids) category_id(category_id);
  SQL
  create_view "delivery_slot_timestamps", sql_definition: <<-SQL
      SELECT delivery_slots.id,
      delivery_slots.day,
      delivery_slots.start,
      delivery_slots."end",
      COALESCE(delivery_slots.retailer_delivery_zone_id, 0) AS retailer_delivery_zone_id,
      delivery_slots.orders_limit,
      delivery_slots.products_limit,
      delivery_slots.products_limit_margin,
      delivery_slots.is_active,
      delivery_slots.retailer_id,
      delivery_slots.retailer_service_id,
      ((
          CASE
              WHEN (delivery_slots.retailer_service_id = 1) THEN rdz.delivery_slot_skip_time
              ELSE rhs.delivery_slot_skip_time
          END)::double precision * '00:00:01'::interval) AS delivery_slot_skip_time,
      (
          CASE
              WHEN (delivery_slots.retailer_service_id = 1) THEN rdz.cutoff_time
              ELSE rhs.cutoff_time
          END)::double precision AS cutoff_time,
      (
          CASE
              WHEN ((r.date_time_offset)::text = 'Asia/Dubai'::text) THEN '04:00:00'::text
              WHEN ((r.date_time_offset)::text = 'Asia/Riyadh'::text) THEN '03:00:00'::text
              ELSE '00:00:00'::text
          END)::interval AS zone_time,
      r.date_time_offset,
      (ts.dates + ((delivery_slots.start)::double precision * '00:00:01'::interval)) AS slot_start,
      (ts.dates + ((delivery_slots."end")::double precision * '00:00:01'::interval)) AS slot_end
     FROM ((((delivery_slots
       JOIN ( SELECT (CURRENT_DATE + s.a) AS dates,
              (date_part('dow'::text, (CURRENT_DATE + s.a)) + (1)::double precision) AS wday
             FROM generate_series(0, 15, 1) s(a)) ts ON ((ts.wday = (delivery_slots.day)::double precision)))
       JOIN retailers r ON ((delivery_slots.retailer_id = r.id)))
       JOIN retailer_has_services rhs ON (((rhs.retailer_service_id = delivery_slots.retailer_service_id) AND (rhs.retailer_id = r.id) AND (rhs.is_active = true))))
       LEFT JOIN retailer_delivery_zones rdz ON ((rdz.id = delivery_slots.retailer_delivery_zone_id)))
    WHERE (delivery_slots.is_active = true);
  SQL

  create_view "online_payment_orders", sql_definition: <<-SQL
      SELECT o.id,
      o.shopper_id,
      o.status_id,
      o.retailer_company_name,
      o.shopper_phone_number,
      o.shopper_name,
      o.shopper_address_id,
      o.created_at,
      o.updated_at,
      o.estimated_delivery_at,
      o.accepted_at,
      o.processed_at,
      o.canceled_at,
      o.shopper_deleted,
      o.retailer_deleted,
      o.delivery_type_id,
      o.delivery_slot_id,
      o.delivery_fee,
      o.rider_fee,
      o.service_fee,
      o.vat,
      o.receipt_no,
      o.merchant_reference,
      o.total_value,
      o.final_amount,
      o.card_detail,
      e.name,
      a.detail,
      opl.fort_id,
      opl.merchant_reference AS oplog_merchant_reference,
      opl.amount,
      opl.method,
      opl.status
     FROM (((orders o
       LEFT JOIN analytics a ON (((o.id = a.owner_id) AND ((a.owner_type)::text = 'Order'::text))))
       JOIN events e ON ((a.event_id = e.id)))
       LEFT JOIN online_payment_logs opl ON (((opl.order_id = o.id) AND (((replace((a.detail)::text, '=>'::text, ':'::text))::json ->> 'fort_id'::text) = (opl.fort_id)::text))))
    WHERE ((o.payment_type_id = 3) AND ((e.name)::text ~* 'payment'::text));
  SQL
  create_view "opl_authid", sql_definition: <<-SQL
      SELECT opl.id,
      opl.order_id,
      opl.fort_id,
      opl.merchant_reference,
      opl.amount,
      opl.method,
      opl.status,
      opl.created_at,
      opl.updated_at,
      pe.authorization_code AS auth_id,
      pe.event_id,
      pe.card_number
     FROM (online_payment_logs opl
       LEFT JOIN payfort_events pe ON (((opl.fort_id)::text = pe.fort_id)));
  SQL

  create_view "order_positions_view", sql_definition: <<-SQL
      SELECT order_positions.id,
      order_positions.order_id,
      order_positions.product_id,
      order_positions.amount,
      order_positions.was_in_shop,
      order_positions.product_barcode,
      order_positions.product_brand_name,
      order_positions.product_name,
      order_positions.product_description,
      order_positions.product_shelf_life,
      order_positions.product_size_unit,
      order_positions.product_country_alpha2,
      order_positions.product_location_id,
      order_positions.product_category_name,
      order_positions.product_subcategory_name,
      order_positions.shop_price_cents,
      order_positions.shop_price_currency,
      order_positions.shop_id,
      order_positions.shop_price_dollars,
      order_positions.commission_value,
      order_positions.category_id,
      order_positions.subcategory_id,
      order_positions.brand_id,
      order_positions.is_promotional,
      order_positions.promotional_price,
      (((order_positions.order_id)::character varying)::text || ((order_positions.product_id)::character varying)::text) AS order_product,
      orders.status_id,
      categories.pickup_priority
     FROM ((order_positions
       JOIN orders ON ((order_positions.order_id = orders.id)))
       LEFT JOIN categories ON ((order_positions.subcategory_id = categories.id)));
  SQL
  create_view "order_substitutions_view", sql_definition: <<-SQL
      SELECT order_substitutions.id,
      order_substitutions.order_id,
      order_substitutions.product_id,
      order_substitutions.substituting_product_id,
      order_substitutions.shopper_id,
      order_substitutions.retailer_id,
      order_substitutions.is_selected,
      order_substitutions.created_at,
      order_substitutions.updated_at,
      order_substitutions.substitute_detail,
      order_substitutions.shop_promotion_id,
      (((order_substitutions.order_id)::character varying)::text || ((order_substitutions.product_id)::character varying)::text) AS order_product
     FROM order_substitutions;
  SQL

  create_view "pickup_loc", sql_definition: <<-SQL
      SELECT pickup_locations.id,
      pickup_locations.retailer_id,
      pickup_locations.details,
      pickup_locations.details_ar,
      pickup_locations.is_active,
      pickup_locations.photo_file_name,
      pickup_locations.photo_content_type,
      pickup_locations.photo_file_size,
      pickup_locations.photo_updated_at,
      pickup_locations.created_at,
      pickup_locations.updated_at,
      st_x((pickup_locations.lonlat)::geometry) AS longitude,
      st_y((pickup_locations.lonlat)::geometry) AS latitude
     FROM pickup_locations;
  SQL
  create_view "retailer_available_slots", sql_definition: <<-SQL
      SELECT delivery_slot_timestamps.id,
      dense_rank() OVER (PARTITION BY delivery_slot_timestamps.retailer_service_id, delivery_slot_timestamps.retailer_id, delivery_slot_timestamps.retailer_delivery_zone_id ORDER BY delivery_slot_timestamps.slot_start) AS slot_rank,
      concat(date_part('year'::text, delivery_slot_timestamps.slot_start), lpad((date_part('week'::text, (delivery_slot_timestamps.slot_start + '1 day'::interval)))::text, 2, '0'::text), delivery_slot_timestamps.id) AS usid,
      delivery_slot_timestamps.day,
      delivery_slot_timestamps.start,
      delivery_slot_timestamps."end",
      delivery_slot_timestamps.retailer_delivery_zone_id,
      delivery_slot_timestamps.orders_limit,
      delivery_slot_timestamps.products_limit,
      delivery_slot_timestamps.products_limit_margin,
      delivery_slot_timestamps.retailer_id,
      delivery_slot_timestamps.retailer_service_id,
      timezone((delivery_slot_timestamps.date_time_offset)::text, delivery_slot_timestamps.slot_start) AS slot_start,
      timezone((delivery_slot_timestamps.date_time_offset)::text, delivery_slot_timestamps.slot_end) AS slot_end,
      COALESCE(sum(order_positions.amount), (0)::bigint) AS total_products,
      totals.total_limit,
      totals.total_margin,
      count(DISTINCT orders.id) AS total_orders,
      totals.total_orders_limit,
      date_part('week'::text, (delivery_slot_timestamps.slot_start + '1 day'::interval)) AS week,
      delivery_slot_timestamps.cutoff_time,
      delivery_slot_timestamps.delivery_slot_skip_time AS delivery_slot_skip_hours,
      delivery_slot_timestamps.date_time_offset
     FROM ((((delivery_slot_timestamps
       JOIN delivery_slots_capacity_mv totals ON (((totals.dsstart = delivery_slot_timestamps.start) AND (totals.dsday = delivery_slot_timestamps.day) AND (totals.retailer_id = delivery_slot_timestamps.retailer_id) AND (totals.retailer_service_id = delivery_slot_timestamps.retailer_service_id))))
       JOIN delivery_slots ds ON (((ds.start = delivery_slot_timestamps.start) AND (ds.day = delivery_slot_timestamps.day) AND (ds.retailer_id = delivery_slot_timestamps.retailer_id) AND (ds.retailer_service_id = delivery_slot_timestamps.retailer_service_id))))
       LEFT JOIN orders ON (((orders.delivery_slot_id = ds.id) AND (orders.status_id <> ALL (ARRAY['-1'::integer, 4])) AND (date(orders.estimated_delivery_at) = date(delivery_slot_timestamps.slot_start)))))
       LEFT JOIN order_positions ON ((order_positions.order_id = orders.id)))
    WHERE (delivery_slot_timestamps.slot_start > (((CURRENT_TIMESTAMP + delivery_slot_timestamps.zone_time) + delivery_slot_timestamps.delivery_slot_skip_time) +
          CASE
              WHEN (delivery_slot_timestamps.cutoff_time > (0)::double precision) THEN
              CASE
                  WHEN (date_part('epoch'::text, ((CURRENT_TIMESTAMP + delivery_slot_timestamps.zone_time))::time without time zone) > delivery_slot_timestamps.cutoff_time) THEN ((((((CURRENT_TIMESTAMP + delivery_slot_timestamps.zone_time))::date + 2))::timestamp with time zone - CURRENT_TIMESTAMP) + delivery_slot_timestamps.zone_time)
                  ELSE ((((((CURRENT_TIMESTAMP + delivery_slot_timestamps.zone_time))::date + 1))::timestamp with time zone - CURRENT_TIMESTAMP) + delivery_slot_timestamps.zone_time)
              END
              ELSE '00:00:00'::interval
          END))
    GROUP BY delivery_slot_timestamps.id, totals.total_limit, totals.total_margin, totals.total_orders_limit, delivery_slot_timestamps.slot_start, delivery_slot_timestamps.day, delivery_slot_timestamps.start, delivery_slot_timestamps.slot_end, delivery_slot_timestamps.retailer_id, delivery_slot_timestamps.products_limit_margin, delivery_slot_timestamps.products_limit, delivery_slot_timestamps.orders_limit, delivery_slot_timestamps.retailer_delivery_zone_id, delivery_slot_timestamps."end", delivery_slot_timestamps.retailer_service_id, delivery_slot_timestamps.cutoff_time, delivery_slot_timestamps.delivery_slot_skip_time, delivery_slot_timestamps.date_time_offset
   HAVING (((totals.total_orders_limit = 0) OR (totals.total_orders_limit > count(DISTINCT orders.id))) AND ((totals.total_limit = 0) OR ((totals.total_limit > COALESCE(sum(order_positions.amount), (0)::bigint)) AND ((((COALESCE(sum(order_positions.amount), (0)::bigint))::numeric / ((totals.total_limit)::numeric * 1.0)) <= 0.7) OR ((totals.total_limit + totals.total_margin) >= (COALESCE(sum(order_positions.amount), (0)::bigint) + 0))))))
    ORDER BY delivery_slot_timestamps.slot_start, delivery_slot_timestamps.day, delivery_slot_timestamps.start;
  SQL
  create_view "retailer_available_slots_mv", materialized: true, sql_definition: <<-SQL
      SELECT retailer_available_slots.id,
      retailer_available_slots.slot_rank,
      retailer_available_slots.usid,
      retailer_available_slots.day,
      retailer_available_slots.start,
      retailer_available_slots."end",
      retailer_available_slots.retailer_delivery_zone_id,
      retailer_available_slots.orders_limit,
      retailer_available_slots.products_limit,
      retailer_available_slots.products_limit_margin,
      retailer_available_slots.retailer_id,
      retailer_available_slots.retailer_service_id,
      retailer_available_slots.slot_start,
      retailer_available_slots.slot_end,
      retailer_available_slots.total_products,
      retailer_available_slots.total_limit,
      retailer_available_slots.total_margin,
      retailer_available_slots.total_orders,
      retailer_available_slots.total_orders_limit,
      retailer_available_slots.week,
      retailer_available_slots.cutoff_time,
      retailer_available_slots.delivery_slot_skip_hours,
      retailer_available_slots.date_time_offset
     FROM retailer_available_slots
    WHERE (retailer_available_slots.slot_rank = 1);
  SQL
  add_index "retailer_available_slots_mv", ["usid"], name: "index_retailer_available_slots_mv", unique: true

  create_view "shop_join_retailer", sql_definition: <<-SQL
      SELECT s.id,
      s.retailer_id,
      s.product_id,
      round(((s.price_dollars)::numeric + ((s.price_cents)::numeric / 100.0)), 2) AS full_price,
      s.price_currency,
      s.product_rank,
      s.is_published,
      s.is_available,
      s.is_promotional,
      s.detail,
      s.promotion_only,
      s.available_for_sale,
      r.with_stock_level,
      r.slug,
      s.created_at,
      s.updated_at
     FROM (shops s
       JOIN retailers r ON ((s.retailer_id = r.id)))
    WHERE (s.retailer_id = r.id);
  SQL
end
