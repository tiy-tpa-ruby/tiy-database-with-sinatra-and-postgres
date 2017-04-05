# courses
# ----------------------------
# id
# name
# subject
# start_date
# end_date
# intensive
# cost
# number_of_seats_available
# created_at
# updated_at
# employee_id

# variable name (and file name) rule is lowercase, snake_case
# Class name rule is CamelCase

class Course < ActiveRecord::Base
  has_many :enrollments
  has_many :employees, through: :enrollments
end
