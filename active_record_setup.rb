require 'active_record'

ActiveRecord::Base.logger = Logger.new(STDOUT)
ActiveRecord::Base.establish_connection(
  adapter: "postgresql",
  database: "tiy-database"
)

# Bring in the employee code
require_relative 'employee'
# Bring in the course code
require_relative 'course'
# Bring in the enrollment code
require_relative 'enrollment'
