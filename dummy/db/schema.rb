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

ActiveRecord::Schema.define(version: 20160818205534) do

  create_table "memos", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer  "project_id"
  end

  create_table "monarchy_hierarchies", force: :cascade do |t|
    t.integer  "parent_id"
    t.integer  "resource_id",   null: false
    t.string   "resource_type", null: false
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.index ["parent_id"], name: "index_monarchy_hierarchies_on_parent_id"
    t.index ["resource_id"], name: "index_monarchy_hierarchies_on_resource_id"
  end

  create_table "monarchy_hierarchy_hierarchies", id: false, force: :cascade do |t|
    t.integer "ancestor_id",   null: false
    t.integer "descendant_id", null: false
    t.integer "generations",   null: false
    t.index ["ancestor_id", "descendant_id", "generations"], name: "hierarchy_anc_desc_idx", unique: true
    t.index ["descendant_id"], name: "hierarchy_desc_idx"
  end

  create_table "monarchy_members", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "hierarchy_id"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
    t.index ["hierarchy_id"], name: "index_monarchy_members_on_hierarchy_id"
    t.index ["user_id"], name: "index_monarchy_members_on_user_id"
  end

  create_table "monarchy_members_roles", force: :cascade do |t|
    t.integer  "role_id"
    t.integer  "member_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["member_id"], name: "index_monarchy_members_roles_on_member_id"
    t.index ["role_id", "member_id"], name: "index_monarchy_members_roles_on_role_id_and_member_id", unique: true
    t.index ["role_id"], name: "index_monarchy_members_roles_on_role_id"
  end

  create_table "monarchy_roles", force: :cascade do |t|
    t.string   "name",                              null: false
    t.integer  "level",             default: 0,     null: false
    t.integer  "inherited_role_id"
    t.boolean  "inherited",         default: false, null: false
    t.datetime "created_at",                        null: false
    t.datetime "updated_at",                        null: false
    t.index ["inherited"], name: "index_monarchy_roles_on_inherited"
    t.index ["inherited_role_id"], name: "index_monarchy_roles_on_inherited_role_id"
    t.index ["level"], name: "index_monarchy_roles_on_level"
    t.index ["name"], name: "index_monarchy_roles_on_name", unique: true
  end

  create_table "projects", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer  "parent_id"
  end

  create_table "resources", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "statuses", force: :cascade do |t|
    t.string   "name"
    t.integer  "project_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "tasks", force: :cascade do |t|
    t.string   "name"
    t.integer  "resource_id"
    t.string   "resource_type"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

end
