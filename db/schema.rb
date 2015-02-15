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

ActiveRecord::Schema.define(version: 20150215204046) do

  create_table "generated_photos", force: :cascade do |t|
    t.integer "original_photo_id"
    t.string  "aws_url"
    t.boolean "confirmed"
  end

  create_table "members", force: :cascade do |t|
    t.string "name"
    t.string "ip"
    t.string "phone_number"
  end

  create_table "original_photos", force: :cascade do |t|
    t.integer "member_id"
    t.string  "phone_number"
    t.string  "aws_url"
    t.string  "body"
  end

  create_table "users", force: :cascade do |t|
    t.string "name"
  end

end
