class CreateCorrects < ActiveRecord::Migration[6.1]
  def change
    create_table :corrects do |t|
      t.integer :user_id, null: false
      t.integer :chinese_character_id, null: false
      t.boolean :correct_of_reading, null: false, default: false
      t.boolean :correct_of_meaning, null: false, default: false
      t.timestamps
    end
  end
end
