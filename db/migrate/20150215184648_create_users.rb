class CreateUsers < ActiveRecord::Migration
  def change
     create_table :members do |t|
        t.string :name
        t.string :ip
        t.string :phone_number
        t.string :password
        t.string :email
     end
  end
end
