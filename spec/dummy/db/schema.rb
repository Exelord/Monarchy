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

ActiveRecord::Schema.define(version: 20160502212213) do

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
  end

  create_table "monarchy_hierarchy_hierarchies", id: false, force: :cascade do |t|
    t.integer "ancestor_id",   null: false
    t.integer "descendant_id", null: false
    t.integer "generations",   null: false
  end

  add_index "monarchy_hierarchy_hierarchies", ["ancestor_id", "descendant_id", "generations"], name: "hierarchy_anc_desc_idx", unique: true
  add_index "monarchy_hierarchy_hierarchies", ["descendant_id"], name: "hierarchy_desc_idx"

  create_table "monarchy_members", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "hierarchy_id"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  create_table "monarchy_members_roles", force: :cascade do |t|
    t.integer  "role_id"
    t.integer  "member_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "monarchy_members_roles", ["role_id", "member_id"], name: "index_monarchy_members_roles_on_role_id_and_member_id", unique: true

  create_table "monarchy_roles", force: :cascade do |t|
    t.string   "name",                      null: false
    t.integer  "level",      default: 0,    null: false
    t.boolean  "inherited",  default: true, null: false
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
  end

  add_index "monarchy_roles", ["name"], name: "index_monarchy_roles_on_name", unique: true

  create_table "projects", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.integer  "resource_id"
  end

  create_table "resources", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

end
