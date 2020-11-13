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

ActiveRecord::Schema.define(version: 20201109201903) do

  create_table "aws_plans", force: :cascade do |t|
    t.integer "migrations_aws_vm_id", null: false
    t.integer "inspection_export_id", null: false
    t.string "salt_minion"
    t.integer "status"
    t.string "notes"
    t.string "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["inspection_export_id"], name: "index_aws_plans_on_inspection_export_id"
    t.index ["migrations_aws_vm_id"], name: "index_aws_plans_on_migrations_aws_vm_id"
  end

  create_table "default_inspection_filters", force: :cascade do |t|
    t.string "scope", null: false
    t.string "definition", null: false
    t.boolean "enable", default: true
    t.string "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "delayed_jobs", force: :cascade do |t|
    t.integer "priority", default: 0, null: false
    t.integer "attempts", default: 0, null: false
    t.text "handler", null: false
    t.text "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string "locked_by"
    t.string "queue"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["priority", "run_at"], name: "delayed_jobs_priority"
  end

  create_table "inspection_exports", force: :cascade do |t|
    t.integer "inspection_id", null: false
    t.integer "export_type", default: 0
    t.string "unmanaged_files_excludes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["inspection_id"], name: "index_inspection_exports_on_inspection_id"
  end

  create_table "inspection_filters", force: :cascade do |t|
    t.integer "inspection_id", null: false
    t.string "scope", null: false
    t.string "definition", null: false
    t.boolean "enable", default: true
    t.string "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["inspection_id"], name: "index_inspection_filters_on_inspection_id"
  end

  create_table "inspections", force: :cascade do |t|
    t.integer "machine_id", null: false
    t.text "scopes", default: "--- []\n", null: false
    t.string "description"
    t.text "notes"
    t.datetime "start"
    t.string "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["machine_id"], name: "index_inspections_on_machine_id"
  end

  create_table "machines", force: :cascade do |t|
    t.string "fqdn", null: false
    t.integer "port", default: 22, null: false
    t.string "nickname", null: false
    t.text "notes"
    t.string "user", default: "root", null: false
    t.text "key", null: false
    t.boolean "meets_prerequisites"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["fqdn"], name: "index_machines_on_fqdn", unique: true
  end

  create_table "migrations_aws_vms", force: :cascade do |t|
    t.string "instance_id"
    t.string "region"
    t.string "image_id"
    t.string "instance_type"
    t.string "key_name"
    t.string "subnet_id"
    t.string "security_id"
    t.string "availability_zone"
    t.string "vpc_id"
    t.string "iam_role"
    t.string "salt_minion"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

end
