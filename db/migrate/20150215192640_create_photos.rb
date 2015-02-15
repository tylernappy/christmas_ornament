class CreatePhotos < ActiveRecord::Migration
  def change
     create_table :generated_photos do |t|
        t.integer :original_photo_id
        t.string :aws_url
        t.boolean :confirmed
     end
  end
end
