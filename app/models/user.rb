class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :corrects, dependent: :destroy

  enum read_level: {
    sixth_grade_elementary_school_student: 0,
    first_year_junior_high_school_student: 1,
    second_year_junior_high_school_student: 2,
    third_year_junior_high_school_student: 3,
    first_year_high_school_student: 4,
    cannnot_registrate_level: 5
  }, _prefix: true

  enum mean_level: {
    sixth_grade_elementary_school_student: 0,
    first_year_junior_high_school_student: 1,
    second_year_junior_high_school_student: 2,
    third_year_junior_high_school_student: 3,
    first_year_high_school_student: 4,
    cannnot_registrate_level: 5
  }, _prefix: true

end
