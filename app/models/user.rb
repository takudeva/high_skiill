class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :corrects, dependent: :destroy

  enum read_level: {
    none: 0,
    sixth_grade_elementary_school_student: 1,
    first_year_junior_high_school_student: 2,
    second_year_junior_high_school_student: 3,
    third_year_junior_high_school_student: 4,
    first_year_high_school_student: 5
  }

  enum mean_level: {
    none: 0,
    sixth_grade_elementary_school_student: 1,
    first_year_junior_high_school_student: 2,
    second_year_junior_high_school_student: 3,
    third_year_junior_high_school_student: 4,
    first_year_high_school_student: 5
  }

end
