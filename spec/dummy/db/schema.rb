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

ActiveRecord::Schema.define(version: 20160306124820) do

<<<<<<< Updated upstream
=======
<<<<<<< Updated upstream
  create_table "hierarchies", force: :cascade do |t|
=======
>>>>>>> Stashed changes
  create_table "memos", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "projects", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "resources", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer  "memo_id"
  end

<<<<<<< Updated upstream
  create_table "tonarchy_hierarchies", force: :cascade do |t|
=======
  create_table "monarchy_hierarchies", force: :cascade do |t|
>>>>>>> Stashed changes
>>>>>>> Stashed changes
    t.integer  "parent_id"
    t.integer  "resource_id",   null: false
    t.string   "resource_type", null: false
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
  end

<<<<<<< Updated upstream
  create_table "tonarchy_hierarchy_hierarchies", id: false, force: :cascade do |t|
=======
<<<<<<< Updated upstream
  create_table "hierarchy_hierarchies", id: false, force: :cascade do |t|
=======
  create_table "monarchy_hierarchy_hierarchies", id: false, force: :cascade do |t|
>>>>>>> Stashed changes
>>>>>>> Stashed changes
    t.integer "ancestor_id",   null: false
    t.integer "descendant_id", null: false
    t.integer "generations",   null: false
  end

<<<<<<< Updated upstream
  add_index "tonarchy_hierarchy_hierarchies", ["ancestor_id", "descendant_id", "generations"], name: "hierarchy_anc_desc_idx", unique: true
  add_index "tonarchy_hierarchy_hierarchies", ["descendant_id"], name: "hierarchy_desc_idx"

  create_table "tonarchy_members", force: :cascade do |t|
=======
<<<<<<< Updated upstream
  add_index "hierarchy_hierarchies", ["ancestor_id", "descendant_id", "generations"], name: "hierarchy_anc_desc_idx", unique: true
  add_index "hierarchy_hierarchies", ["descendant_id"], name: "hierarchy_desc_idx"

  create_table "members", force: :cascade do |t|
=======
  add_index "monarchy_hierarchy_hierarchies", ["ancestor_id", "descendant_id", "generations"], name: "hierarchy_anc_desc_idx", unique: true
  add_index "monarchy_hierarchy_hierarchies", ["descendant_id"], name: "hierarchy_desc_idx"

  create_table "monarchy_members", force: :cascade do |t|
>>>>>>> Stashed changes
>>>>>>> Stashed changes
    t.integer  "user_id"
    t.integer  "hierarchy_id"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

<<<<<<< Updated upstream
  create_table "tonarchy_members_roles", force: :cascade do |t|
=======
<<<<<<< Updated upstream
  create_table "members_roles", force: :cascade do |t|
=======
  create_table "monarchy_members_roles", force: :cascade do |t|
>>>>>>> Stashed changes
>>>>>>> Stashed changes
    t.integer  "role_id"
    t.integer  "member_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

<<<<<<< Updated upstream
  add_index "tonarchy_members_roles", ["role_id", "member_id"], name: "index_tonarchy_members_roles_on_role_id_and_member_id", unique: true

  create_table "tonarchy_roles", force: :cascade do |t|
=======
<<<<<<< Updated upstream
  add_index "members_roles", ["role_id", "member_id"], name: "index_members_roles_on_role_id_and_member_id", unique: true

  create_table "memos", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "projects", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "resources", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer  "memo_id"
  end

  create_table "roles", force: :cascade do |t|
=======
  add_index "monarchy_members_roles", ["role_id", "member_id"], name: "index_monarchy_members_roles_on_role_id_and_member_id", unique: true

  create_table "monarchy_roles", force: :cascade do |t|
>>>>>>> Stashed changes
>>>>>>> Stashed changes
    t.string   "name",                      null: false
    t.integer  "level",      default: 0,    null: false
    t.boolean  "inherited",  default: true, null: false
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
  end

<<<<<<< Updated upstream
  add_index "tonarchy_roles", ["name"], name: "index_tonarchy_roles_on_name", unique: true
=======
<<<<<<< Updated upstream
  add_index "roles", ["name"], name: "index_roles_on_name", unique: true
=======
  add_index "monarchy_roles", ["name"], name: "index_monarchy_roles_on_name", unique: true
>>>>>>> Stashed changes
>>>>>>> Stashed changes

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

end
