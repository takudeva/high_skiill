class ChineseCharacter < ApplicationRecord

  has_many :corrects, dependent: :destroy

end
