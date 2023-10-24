class CreateCorrects < ActiveRecord::Migration[6.1]
  def change
    create_table :corrects do |t|
      t.integer :user_id, null: false
      t.integer :chinese_character_id, null: false
      t.integer :type, null: false
      t.boolean :correct_of_reading, null: true
      t.boolean :correct_of_meaning, null: true
      t.timestamps
    end
  end
end
