class Employee < ActiveRecord::Base
  validates :name, presence: true
  validates :position, inclusion: { in: %w{Instructor Student}, message: "%{value} must be Instructor or Student" }

  has_many :enrollments
  has_many :courses, through: :enrollments
  # has_many :courses, :through => :enrollments

  self.primary_key = "id"

  def monthly_salary
    return salary.to_i / 12
  end
end
