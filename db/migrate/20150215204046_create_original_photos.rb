class CreateOriginalPhotos < ActiveRecord::Migration
  def change
     create_table :original_photos do |t|
        t.integer :member_id
        t.string :phone_number
        t.string :aws_url
        t.string :body
     end
  end
end
