# id
# employee_id
# course_id
# created_at
# updated_at
class Enrollment < ActiveRecord::Base
  belongs_to :employee
  belongs_to :course
end
