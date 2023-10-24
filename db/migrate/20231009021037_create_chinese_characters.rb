class CreateChineseCharacters < ActiveRecord::Migration[6.1]
  def change
    create_table :chinese_characters do |t|
      t.string :chinese_character, null: false
      t.string :reading_of_chinese_character, null: false
      t.string :meaning_of_chinese_character, null: false
      t.integer :level_of_chinese_character, null: false
      t.integer :number_for_each_level, null: false
      t.timestamps
    end
  end
end
