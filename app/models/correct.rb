class Correct < ApplicationRecord

  belongs_to :user
  belongs_to :chinese_character

  self.inheritance_column = :_type_disabled

end
