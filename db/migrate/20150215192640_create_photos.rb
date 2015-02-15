class CreatePhotos < ActiveRecord::Migration
  def change
     create_table :photos do |t|
        t.integer :member_id
        t.string :phone_number
        t.string :aws_url
        t.boolean :confirmed
     end
  end
end
