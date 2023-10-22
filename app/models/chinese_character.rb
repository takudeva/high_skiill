class ChineseCharacter < ApplicationRecord

  has_many :corrects, dependent: :destroy

  enum level_of_chinese_character: {
    sixth_grade_elementary_school_student: 0,
    first_year_junior_high_school_student: 1,
    second_year_junior_high_school_student: 2,
    third_year_junior_high_school_student: 3,
    first_year_high_school_student: 4
  }

end
